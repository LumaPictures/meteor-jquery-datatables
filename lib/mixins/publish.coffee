DataTableMixins.Publish =
  # ##### @countCollection
  # The name of the client only collection that tracks the collection counts for its base and filtered queries.
  countCollection: "datatable_subscription_count"

  # ##### @publish()
  # A static method for creating paginated DataTables publications. `DataTable.publish` takes a subscription name (string)
  # and a Meteor Collection as parameters.
  publish: ( subscription, collection ) ->
    Match.test subscription, String
    Match.test collection, Object

    # ###### Meteor.publish
    # The publication that DataTable provides is a paginated and filtered subset of the base query defined by the DataTable
    # on the client.
    # ###### Parameters
    #   + baseQuery: ( object ) the initial query on the dataset. Eventually this may be defined only on the server, to prevent
    # clients from gaining access to the entire dataset if they modify the baseQuery.
    #   + filteredQuery: ( object ) the filter being applied by the client datatable's current state.
    #   + options : ( object ) sort and pagination options supplied by the client datatables's current state.
    Meteor.publish subscription, ( collectionName, baseQuery, filteredQuery, options ) ->
      self = @
      initialized = false
      countInitialized = false
      Match.test baseQuery, Object
      Match.test filteredQuery, Object
      Match.test options, Object
      DataTable.log "#{ subscription }:query:base", baseQuery
      DataTable.log "#{ subscription }:query:filtered", filteredQuery
      DataTable.log "#{ subscription }:options", options

      # ###### updateCount
      # Update the count values of the client DataTableCount Collection to reflect the current filter state.
      updateCount = ( ready, added = false ) ->
        # `ready` is the initialization state of the subscriptions observe handle. Counts are only published after the observes
        # are initialized.
        if ready
          total = collection.find( baseQuery ).count()
          DataTable.log "#{ subscription }:count:total", total
          filtered = collection.find( filteredQuery ).count()
          DataTable.log "#{ subscription }:count:filtered", filtered
          # `added` is a flag that is set to true on the initial insert into the DaTableCount collection from this subscription.
          if added
            self.added( DataTable.countCollection, collectionName, { count: total } )
            self.added( DataTable.countCollection, "#{ collectionName }_filtered", { count: filtered } )
          else
            self.changed( DataTable.countCollection, collectionName, { count: total } )
            self.changed( DataTable.countCollection, "#{ collectionName }_filtered", { count: filtered } )

      # ###### observe
      # DataTable observes just the filtered and paginated subset of the Collection. This is for performance reasons as
      # observing large datasets entirely is unrealistic. The observe callbacks use `At` due to the sort and limit options
      # passed the the observer.
      handle = collection.find( filteredQuery, options ).observe
        # ###### addedAt()
        # Updates the count and sends the new doc to the client.
        addedAt: ( doc, index, before ) ->
          updateCount initialized
          self.added collectionName, doc._id, doc
          DataTable.log "#{ subscription }:added", doc._id
        # ###### changedAt()
        # Updates the count and sends the changed properties to the client.
        changedAt: ( newDoc, oldDoc, index ) ->
          updateCount initialized
          self.changed collectionName, newDoc._id, newDoc
          DataTable.log "#{ subscription }:changed", newDoc._id
        # ###### removedAt()
        # Updates the count and removes the document from the client.
        removedAt: ( doc, index ) ->
          updateCount initialized
          self.removed collectionName, doc._id
          DataTable.log "#{ subscription }:removed", doc._id
      # After the observer is initialized the `initialized` flag is set to true, the initial count is published,
      # and the publication is marked as `ready()`
      initialized = true
      updateCount initialized, true
      self.ready()

      # This is an attempt to monitor the last page in the dataset for changes, this is due to datatable on the client
      # breaking when the last page no longer contains any data, or is no longer the last page.
      lastPage = collection.find( filteredQuery ).count() - options.limit
      if lastPage > 0
        countOptions = options
        countOptions.skip = lastPage
        countHandle = collection.find( filteredQuery, countOptions ).observe
          addedAt: -> updateCount countInitialized
          changedAt: -> updateCount countInitialized
          removedAt: -> updateCount countInitialized
        countInitialized = true

      # When the publication is terminated the observers are stopped to prevent memory leaks.
      self.onStop ->
        handle.stop()
        if countHandle
          countHandle.stop()