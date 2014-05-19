# ### Collection Counts
# Datatables maintains counts of both the base query and filtered query reactively.
# These counts are published by the datatables publication
DataTableMixins.Collection =
  countCollection: if Meteor.isClient then new Meteor.Collection "datatable_count" else "datatable_count"
  extended: ->
    @include
      # ##### prepareCollection()
      prepareCollection: ->
        if Meteor.isClient
          if @subscription
            @data.collection = new Meteor.Collection @id()
            @addGetterSetter "data", "collection"
        if Meteor.isServer
          throw new Error "collection property is not defined" unless @data.collection
          @addGetterSetter "data", "collection"

      # ##### collectionName()
      collectionName: ->
        return @collection()._name or false

      # ##### prepareCountCollection()
      prepareCountCollection: ->
        unless @countCollection
          @data.countCollection = DataTableComponent.countCollection
          @addGetterSetter "data", "countCollection"

    if Meteor.isClient
      @include
        # #### `collection` Meteor Collection ( required )
        # This is the collection that houses the documents your datatable is displaying
        # and must be defined on both the client and the server.

        # ##### getTotalCount()
        totalCount: ->
          return @countCollection().findOne( @collectionName() ).count or 0

        # ##### getFilteredCount()
        filteredCount: ->
          return @countCollection().findOne( "#{ @collectionName() }_filtered" ).count or 0
