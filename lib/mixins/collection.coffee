# ### Collection Counts
# Datatables maintains counts of both the base query and filtered query reactively.
# These counts are published by the datatables publication
DataTableMixins.Collection =
  # #### `collection` Meteor Collection ( required )
  # This is the collection that houses the documents your datatable is displaying
  # and must be defined on both the client and the server.
  setCollection: ( collection ) ->
    Match.test collection, Object
    @setData 'collection', collection
    @log 'collection:set', collection

  # ##### setCountCollection()
  setCountCollection: ( collection ) ->
    Match.test collection, Object
    @setData 'countCollection', collection
    @log 'collection:count:set', collection

  # ##### prepareCollection()
  prepareCollection: ->
    if @getCollection() and @getQuery()
      @prepareCountCollection()

  # ##### prepareCountCollection()
  prepareCountCollection: ->
    collection = @getData().countCollection or DataTable.countCollection
    @setCountCollection collection

  # ##### getCollection()
  getCollection: ->
    return @getData().collection or false

  # ##### getCountCollection()
  getCountCollection: ->
    return @getData().countCollection or false

  # ##### getTotalCount()
  getTotalCount: ->
    return @getCountCollection().findOne( "#{ @getSubscription() }#{ @getQueryAsString() }" ).count or 0

  # ##### getFilteredCount()
  getFilteredCount: ->
    return @getCountCollection().findOne( "#{ @getSubscription() }#{ @getQueryAsString() }_filtered" ).count or 0
