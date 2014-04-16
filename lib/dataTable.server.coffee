class DataTable
  @debug: false

  @countCollection: "datatable_subscription_count"

  @isDebug: -> return DataTable.debug or false

  @log: ( message, object ) ->
    if DataTable.isDebug()
      if message.indexOf( DataTable.isDebug() ) isnt -1 or DataTable.isDebug() is "true"
        console.log "dataTable:#{ message } ->", object

  @publish: ( subscription, collection ) ->
    Match.test subscription, String
    Match.test collection, Object
    Meteor.publish subscription, ( baseQuery, filteredQuery, options ) ->
      self = @
      initialized = false
      Match.test baseQuery, Object
      Match.test filteredQuery, Object
      Match.test options, Object
      DataTable.log "#{ subscription }:query:base", baseQuery
      DataTable.log "#{ subscription }:query:filtered", filteredQuery
      DataTable.log "#{ subscription }:options", options
      updateCount = ( first = false ) ->
        if initialized
          total = collection.find( baseQuery ).count()
          DataTable.log "#{ subscription }:count:total", total
          filtered = collection.find( filteredQuery ).count()
          DataTable.log "#{ subscription }:count:filtered", filtered
          if first
            self.added( DataTable.countCollection, subscription, { count: total } )
            self.added( DataTable.countCollection, "#{ subscription }_filtered", { count: filtered } )
          else
            self.changed( DataTable.countCollection, subscription, { count: total } )
            self.changed( DataTable.countCollection, "#{ subscription }_filtered", { count: filtered } )
      handle = collection.find( filteredQuery, options ).observe
        addedAt: ( doc, index, before ) ->
          updateCount()
          self.added collection._name, doc._id, doc
          DataTable.log "added", doc._id
        changedAt: ( newDoc, oldDoc, index ) ->
          updateCount()
          self.changed collection._name, newDoc._id, newDoc
          DataTable.log "changed", newDoc._id
        removedAt: ( doc, index ) ->
          updateCount()
          self.removed collection._name, doc._id
          DataTable.log "removed", doc._id
      initialized = true
      updateCount initialized
      self.onStop -> handle.stop()
      self.ready()