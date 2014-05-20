# #### `subscription` String ( required )
# The name of the subscription your datatable is paging, sorting, and filtering.
# This must be a datatable compatible publication ( for more info see Server )
DataTableMixins.Subscription =
  extended: ->
    if Meteor.isClient
      @include
        # ##### setSubscriptionOptions()
        setSubscriptionOptions: ->
          unless @subscriptionOptions
            @data.subscriptionOptions = undefined
            @addGetterSetter "data", "subscriptionOptions"
          options =
            skip: @tableState().iDisplayStart
            limit: @tableState().iDisplayLength
            sort: @tableState().sort
          @subscriptionOptions options
          @log "subscriptionOptions", @subscriptionOptions()

        # ##### setSubscriptionHandle()
        # Subscribes to the dataset for the current table state and stores the handle for later access.
        setSubscriptionHandle: ->
          if @subscriptionHandle and @subscriptionHandle().stop
            @subscriptionHandle().stop()
          else
            @data.subscriptionHandle = undefined
            @addGetterSetter "data", "subscriptionHandle"
          @subscriptionHandle Meteor.subscribe( @subscription(), @collectionName(), @query(), @tableState().query, @subscriptionOptions() )
          @log "subscriptionHandle", @subscriptionHandle()

        # ##### setSubscriptionAutorun()
        # Creates a reactive computation that runs when the subscription is `ready()`
        # and sets up local cursor ( identical to server except no skip ).
        setSubscriptionAutorun: ( fnCallback ) ->
          Match.test fnCallback, Object
          if @subscriptionAutorun and @subscriptionAutorun().stop
            @subscriptionAutorun().stop()
          else
            @data.subscriptionAutorun = undefined
            @addGetterSetter "data", "subscriptionAutorun"
          @subscriptionAutorun Deps.autorun =>
            if @subscriptionHandle and @subscriptionHandle().ready()
              @log 'fnServerdData:handle:ready', @subscriptionHandle().ready()
              cursorOptions = skip: 0
              cursorOptions.limit = @tableState().iDisplayLength or 10
              if @tableState().sort
                cursorOptions.sort = @tableState().sort
              unless @cursor
                @data.cursor = undefined
                @addGetterSetter "data", "cursor"
              @cursor @collection().find @tableState().query, cursorOptions
              # Here data is fetched from the collection and passed dataTables by calling the `fnCallback()`
              # passed to `fnServerData()`.
              aaData = @cursor().fetch()
              @log 'fnServerData:aaData', aaData
              fnCallback
                # Sends an unaltered copy of `sEcho` ( draw count ) to datatables.
                sEcho: @tableState().sEcho
                # Gets total docs, before filtering i.e. the total number of records in the server collection.
                # Both of these counts come from the `DataTableSubscriptionCount` collection on the client.
                # `DataTableSubscriptionCount` is populated reactively by the DataTables publication for this table.
                # The selector used to retrieve the counts is the subscription name and + '_filtered'.
                iTotalRecords: @totalCount()
                # Gets total records, after filtering i.e. the total number of records after filtering has been applied
                iTotalDisplayRecords: @filteredCount()
                aaData: aaData
          @log "subscriptionAutorun", @subscriptionAutorun()