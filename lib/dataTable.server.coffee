class DataTable
  @debug: false

  @countCollection: "datatable_subscription_count"

  @isDebug: ->
    return DataTable.debug or false

  @log: ( message, object ) ->
    if DataTable.isDebug()
      if message.indexOf( DataTable.isDebug() ) isnt -1 or DataTable.isDebug() is "true"
        console.log "dataTable:#{ message } ->", object

  @publish: ( subscription, collection ) ->
    Match.test subscription, String
    Match.test collection, Object
    Meteor.publish subscription, ( baseQuery, filteredQuery, options ) ->
      Match.test baseQuery, Object
      Match.test filteredQuery, Object
      Match.test options, Object
      DataTable.log "#{ subscription }:query:base", baseQuery
      DataTable.log "#{ subscription }:query:filtered", filteredQuery
      DataTable.log "#{ subscription }:options", options
      total = collection.find( baseQuery ).count()
      DataTable.log "#{ subscription }:count:total", total
      filtered = Browsers.find( filteredQuery ).count()
      DataTable.log "#{ subscription }:count:filtered", filtered
      @added( DataTable.countCollection, subscription, { count: total } )
      @added( DataTable.countCollection, "#{ subscription }_filtered", { count: filtered } )
      return collection.find( filteredQuery, options )