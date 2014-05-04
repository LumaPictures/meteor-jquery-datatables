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
    if @getSubscription()
      @setCollection new Meteor.Collection @getSelector()
      @prepareCountCollection()

  # ##### prepareCountCollection()
  prepareCountCollection: ->
    collection = @getData().countCollection or DataTable.countCollection
    @setCountCollection collection

  # ##### getCollection()
  getCollection: ->
    return @getData().collection or false

  getCollectionName: ->
    return @getCollection()._name or false

  # ##### getCountCollection()
  getCountCollection: ->
    return @getData().countCollection or false

  # ##### getTotalCount()
  getTotalCount: ->
    return @getCountCollection().findOne( @getCollectionName() ).count or 0

  # ##### getFilteredCount()
  getFilteredCount: ->
    return @getCountCollection().findOne( "#{ @getCollectionName() }_filtered" ).count or 0
