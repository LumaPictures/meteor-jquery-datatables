# ## Querying MongoDB
DataTableMixins.QueryBuilder =
  # ##### mapTableState()
  # Take the `aoData` parameter of `fnServerData` and map it into a more usable object.
  mapTableState: (aoData ) ->
    aoData = @arrayToDictionary aoData, 'name'
    @log 'mapTableState:aoData', aoData

    # ##### tableState
    tableState =
      #   + `aoData.sEcho` is a request counter, incremented on every server call
      sEcho: aoData.sEcho.value or 1
      bRegex: aoData.bRegex.value or false
      #   + `aoData.columns` contains the property meta data for each column
      columns: []
      #   + `aoData.iColumns` is the number of columns being displayed
      iColumns: aoData.iColumns.value or 0
      #   + `aoData.iSortingCols` is the number of columns being sorted
      iSortingCols: aoData.iSortingCols.value or 0
      sColumns: aoData.sColumns.value or ""
      #   + `aoData.iDisplayLength` is the number of rows being displayed
      iDisplayLength: aoData.iDisplayLength.value or 10
      #   + `aoData.iDisplayStart` is the number of rows to skip for pagination
      iDisplayStart: aoData.iDisplayStart.value or 0
      #   + `aoData.sSearch` is the datatables search input value
      sSearch: aoData.sSearch.value or ""

    # ##### getDataProp()
    # Function scope helper for getting `aoData` properties.
    getDataProp = ( key, index ) ->
      key = "#{ key }_#{ index }"
      return aoData[ key ].value

    # ##### mapColumns()
    # iterator for setting up columns
    mapColumns = ( index ) ->
      tableState.columns[ getDataProp 'mDataProp', index ] =
        #   + `mDataProp` is the field name
        mDataProp: getDataProp 'mDataProp', index
        #   + `bRegex` is a boolean for if the field has a search input
        bRegex: getDataProp 'bRegex', index
        #   + `bSearchable` is a boolean used to determine which fields are searchable
        bSearchable: getDataProp 'bSearchable', index
        #   + `bSortable` is a boolean used to determine which fields are sortable
        bSortable: getDataProp 'bSortable', index
        #   + `sSearch` contains the column search string if column filters are setup
        sSearch: getDataProp 'sSearch', index
    mapColumns index for index in [ 0..( tableState.iColumns - 1 ) ]

    # ##### mapQuery()
    if tableState.sSearch isnt ""
      # The filter query is initialized as an `$or` of all the searchable columns against the search regex.
      searchQuery = $or: []
      mapQuery = ( key, property ) ->
        unless property.bSearchable is false
          obj = {}
          obj[ key ] =
            $regex: tableState.sSearch
          # Letter case is ignored for all search querys.
            $options: 'i'
          searchQuery.$or.push obj
      for key, property of tableState.columns
        mapQuery key, property
      # If the base query is for all records in the collection, the filter query is the only query run.
      if @getQuery is {}
        tableState.query = searchQuery
      # If the base query is already filter the collection, the filter query is run as an `$and` against it.
      else
        tableState.query =
          $and: [
            @getQuery()
            searchQuery
          ]
    else tableState.query = @getQuery()

    # ##### mapSortOrder()
    # Only runs if columns are being sorted.
    if tableState.iSortingCols > 0
      tableState.sort = {}
      # Sets sort direction for each sorted field, allowing multi column sort.
      mapSortOrder = ( sortIndex ) ->
        sortIndex = sortIndex - 1
        propertyIndex = getDataProp 'iSortCol', sortIndex
        propertyName = getDataProp 'mDataProp', propertyIndex
        switch getDataProp( 'sSortDir', sortIndex )
          when 'asc' then tableState.sort[ propertyName ] = 1
          when 'desc' then tableState.sort[ propertyName ] = -1
      mapSortOrder sortIndex for sortIndex in [ 1..tableState.iSortingCols ]
    return tableState

  # ##### setTableState()
  setTableState: (aoData ) ->
    Match.test aoData, Object
    tableState = @mapTableState aoData
    @setData 'tableState', tableState
    @log 'tableState:set', tableState

  # ##### getTableState()
  getTableState: ->
    return @getData().tableState or false

  # ##### fnServerData()
  # The callback for every dataTables user / reactivity event
  # ###### Parameters
  #   + `sSource` is the currently useless `sAjaxProp` from the options
  #   + `aoData` is an array of objects provided by datatables reflecting its current state
  #   + `fnCallback` is the function that will be called when the server returns a result
  #   + `oSettings` is the datatables settings object
  fnServerData: (sSource, aoData, fnCallback, oSettings ) ->
    # `setTableState()` parses aoData and creates a usable table state object.
    @setTableState aoData
    # `setSubscriptionOptions()` turns the table state into a MongoDB query options object.
    @setSubscriptionOptions()
    # `setSubscriptionHandle()` subscribes the the dataset for the current table state.
    @setSubscriptionHandle()
    # `setSubscriptionAutorun()` creates a Deps.autrun computation. The autorun computation will call datatables fnCallback
    # when the current table state subscription is ready.
    @setSubscriptionAutorun fnCallback