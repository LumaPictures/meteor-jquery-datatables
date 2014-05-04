# #### `subscription` String ( required )
# The name of the subscription your datatable is paging, sorting, and filtering.
# This must be a datatable compatible publication ( for more info see Server )
DataTableMixins.Subscription =
  setSubscription: ( subscription ) ->
    Match.test subscription, Object
    @setData 'subscription', subscription
    @log 'subscription:set', subscription

  # ##### setSubscriptionOptions()
  setSubscriptionOptions: ->
    options =
      skip: @getTableState().iDisplayStart
      limit: @getTableState().iDisplayLength
      sort: @getTableState().sort
    @setData 'subscriptionOptions', options
    @log 'subscription:options:set', options

  # ##### setSubscriptionHandle()
  # Subscribes to the dataset for the current table state and stores the handle for later access.
  setSubscriptionHandle: ->
    if @getSubscriptionHandle()
      @getSubscriptionHandle().stop()
    handle = Meteor.subscribe @getSubscription(), @getCollectionName(), @getQuery(), @getTableState().query, @getSubscriptionOptions()
    @setData 'handle', handle
    @log 'subscription:handle:set', handle

  # ##### setSubscriptionAutorun()
  # Creates a reactive computation that runs when the subscription is `ready()`
  # and sets up local cursor ( identical to server except no skip ).
  setSubscriptionAutorun: ( fnCallback ) ->
    Match.test fnCallback, Object
    if @getSubscriptionAutorun()
      @getSubscriptionAutorun().stop()
    autorun = Deps.autorun =>
      if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
        @log 'fnServerdData:handle:ready', @getSubscriptionHandle().ready()
        cursorOptions = skip: 0
        cursorOptions.limit = @getTableState().iDisplayLength or 10
        if @getTableState().sort
          cursorOptions.sort = @getTableState().sort
        @setCursor @getCollection().find @getTableState().query, cursorOptions
        # Here data is fetched from the collection and passed dataTables by calling the `fnCallback()`
        # passed to `fnServerData()`.
        aaData = @getCursor().fetch()
        @log 'fnServerData:aaData', aaData
        fnCallback
        # Sends an unaltered copy of `sEcho` ( draw count ) to datatables.
          sEcho: @getTableState().sEcho
        # Gets total docs, before filtering i.e. the total number of records in the server collection.
        # Both of these counts come from the `DataTableSubscriptionCount` collection on the client.
        # `DataTableSubscriptionCount` is populated reactively by the DataTables publication for this table.
        # The selector used to retrieve the counts is the subscription name and + '_filtered'.
          iTotalRecords: @getTotalCount()
        # Gets total records, after filtering i.e. the total number of records after filtering has been applied
          iTotalDisplayRecords: @getFilteredCount()
          aaData: aaData
    @setData 'autorun', autorun
    @log 'subscription:autorun:set', autorun

  # ##### getSubscription()
  getSubscription: ->
    return @getData().subscription or false

  # ##### getSubscriptionOptions()
  getSubscriptionOptions: ->
    return @getData().subscriptionOptions or false

  # ##### getSubscriptionHandle()
  getSubscriptionHandle: ->
    return @getData().handle or false

  # ##### getSubscriptionAutorun()
  getSubscriptionAutorun: ->
    return @getData().autorun or false