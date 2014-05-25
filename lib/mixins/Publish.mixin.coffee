DataTableMixins.Publish =
  extended: ->
    if Meteor.isServer
      @include

        # ###### updateCount( Object, Boolean )
        # Update the count values of the client DataTableComponentCount Collection to reflect the current filter state.
        updateCount: ( args, added = false ) ->
          component = @
          # `initialized` is the initialization state of the subscriptions observe handle. Counts are only published after the observes are initialized.
          if args.initialized
            total = component.collection().find( args.baseQuery ).count()
            component.log "#{ component.subscription() }:count:total", total
            filtered = component.collection().find( args.filteredQuery ).count()
            component.log "#{ component.subscription() }:count:filtered", filtered
            # `added` is a flag that is set to true on the initial insert into the DaTableCount collection from this subscription.
            if added
              args.publish.added( component.countCollection(), args.collectionName, { count: total } )
              args.publish.added( component.countCollection(), "#{ args.collectionName }_filtered", { count: filtered } )
            else
              args.publish.changed( component.countCollection(), args.collectionName, { count: total } )
              args.publish.changed( component.countCollection(), "#{ args.collectionName }_filtered", { count: filtered } )

        # ###### observer( Object )
        # DataTableComponent observes just the filtered and paginated subset of the Collection. This is for performance reasons as
        # observing large datasets entirely is unrealistic. The observe callbacks use `At` due to the sort and limit options
        # passed the the observer.
        observer: ( args ) ->
          component = @
          return @collection().find( args.filteredQuery, args.options ).observe

            # ###### addedAt( Object, Number, Number )
            # Updates the count and sends the new doc to the client.
            addedAt: ( doc, index, before ) ->
              component.updateCount args
              args.publish.added args.collectionName, doc._id, doc
              args.publish.added component.collection()._name, doc._id, doc
              component.log "#{ component.subscription() }:added", doc._id

            # ###### changedAt( Object, Object, Number )
            # Updates the count and sends the changed properties to the client.
            changedAt: ( newDoc, oldDoc, index ) ->
              component.updateCount args
              args.publish.changed args.collectionName, newDoc._id, newDoc
              args.publish.changed component.collection()._name, newDoc._id, newDoc
              component.log "#{ component.subscription() }:changed", newDoc._id

            # ###### removedAt( Object, Number )
            # Updates the count and removes the document from the client.
            removedAt: ( doc, index ) ->
              component.updateCount args
              args.publish.removed args.collectionName, doc._id
              args.publish.removed args.collection()._name, doc._id
              component.log "#{ component.subscription() }:removed", doc._id

        # ##### @publish()
        # A static method for creating paginated DataTables publications. `DataTable.publish` takes a subscription name (string)
        # and a Meteor Collection as parameters.
        publish: ->
          # ###### Meteor.publish
          # The publication that DataTable provides is a paginated and filtered subset of the base query defined by the DataTable
          # on the client.
          # ###### Parameters
          #   + collectionName: ( String ) The client collection these documents are being added to.
          #   + baseQuery: ( Object ) the initial query on the dataset.
          #   + filteredQuery: ( Object ) the filter being applied by the client datatable's current state.
          #   + options : ( Object ) sort and pagination options supplied by the client datatables's current state.
          component = @
          Meteor.publish component.subscription(), ( collectionName, baseQuery, filteredQuery, options ) ->
            Match.test baseQuery, Object
            Match.test filteredQuery, Object
            Match.test options, Object
            component.log "#{ component.subscription() }:query:base", baseQuery
            component.log "#{ component.subscription() }:query:filtered", filteredQuery
            component.log "#{ component.subscription() }:options", options

            if _.isFunction component.query()
              queryMethod = _.bind component.query(), @
              query = queryMethod component
            else query = component.query()

            # The baseQuery is an and of the client and server queries, to prevent the client from accessing the entire collection
            baseQuery = $and: [
              query
              baseQuery
            ]

            filteredQuery = $and: [
              query
              baseQuery
            ]

            args =
              publish: @
              initialized: false
              collectionName: collectionName
              baseQuery: baseQuery
              filteredQuery: filteredQuery
              options: options

            # After the observer is initialized the `initialized` flag is set to true, the initial count is published,
            # and the publication is marked as `ready()`
            handle = component.observer args
            args.initialized = true
            component.updateCount args, true
            args.publish.ready()

            # This is an attempt to monitor the last page in the dataset for changes, this is due to datatable on the client
            # breaking when the last page no longer contains any data, or is no longer the last page.
            lastPage = component.collection().find( args.filteredQuery ).count() - args.options.limit
            if lastPage > 0
              countArgs = _.clone args
              countArgs.initialized = false
              countArgs.options.skip = lastPage
              countHandle = component.collection().find( countArgs.filteredQuery, countArgs.options ).observe
                addedAt: -> component.updateCount countArgs
                changedAt: -> component.updateCount countArgs
                removedAt: -> component.updateCount countArgs
              countArgs.initialized = true

            # When the publication is terminated the observers are stopped to prevent memory leaks.
            args.publish.onStop ->
              handle.stop()
              if countHandle
                countHandle.stop()