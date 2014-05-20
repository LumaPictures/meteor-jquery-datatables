# #### `query` MongoDB Selector ( optional )
# The initial filter for your datatable.
# The default query is `{}`
# You should attempt to narrow your selection as much as possbile to improve performance.
DataTableMixins.Query =
  extended: ->
    if Meteor.isClient
      @include
        # ##### arrayToDictionary()
        arrayToDictionary: ( array, key ) ->
          dict = {}
          dict[obj[key]] = obj for obj in array when obj[ key ]?
          dict

        # ##### prepareQuery()
        prepareQuery: ->
          if @subscription
            unless @query
              @data.query = {}
              @addGetterSetter "data", "query"

        # ##### prepareTableState()
        prepareTableState: ->
          if @subscription
            @data.tableState = undefined
            @addGetterSetter "data", "tableState"

        # ##### getDataProp( String, Number, Object )
        # Function scope helper for getting `aoData` properties.
        getDataProp: ( key, index, data ) ->
          key = "#{ key }_#{ index }"
          return data[ key ].value

        # ##### mapColumns( Number, Object )
        # iterator for setting up columns
        mapColumns: ( index, data ) ->
          @tableState().columns[ @getDataProp 'mDataProp', index, data ] =
            #   + `mDataProp` is the field name
            mDataProp: @getDataProp 'mDataProp', index, data
            #   + `bRegex` is a boolean for if the field has a search input
            bRegex: @getDataProp 'bRegex', index, data
            #   + `bSearchable` is a boolean used to determine which fields are searchable
            bSearchable: @getDataProp 'bSearchable', index, data
            #   + `bSortable` is a boolean used to determine which fields are sortable
            bSortable: @getDataProp 'bSortable', index, data
            #   + `sSearch` contains the column search string if column filters are setup
            sSearch: @getDataProp 'sSearch', index, data

        # ##### mapQuery( String, Object, Object )
        mapQuery: ( key, property, searchQuery ) ->
          unless property.bSearchable is false
            obj = {}
            obj[ key ] =
              $regex: @tableState().sSearch
              # Letter case is ignored for all search querys.
              $options: 'i'
            searchQuery.$or.push obj

        # ##### mapSortOrder( Number, Object )
        mapSortOrder: ( sortIndex, data ) ->
          sortIndex = sortIndex - 1
          propertyIndex = @getDataProp 'iSortCol', sortIndex, data
          propertyName = @getDataProp 'mDataProp', propertyIndex, data
          switch @getDataProp( 'sSortDir', sortIndex, data )
            when 'asc' then @tableState().sort[ propertyName ] = 1
            when 'desc' then @tableState().sort[ propertyName ] = -1

        # ##### mapTableState( Array )
        # Take the `aoData` parameter of `fnServerData` and map it into a more usable object.
        mapTableState: ( aoData ) ->
          aoData = @arrayToDictionary aoData, 'name'
          @log 'mapTableState:aoData', aoData

          # ##### tableState
          @tableState
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

          @mapColumns( index, aoData ) for index in [ 0..( @tableState().iColumns - 1 ) ]

          # ##### mapQuery()
          if @tableState().sSearch isnt ""
            # The filter query is initialized as an `$or` of all the searchable columns against the search regex.
            searchQuery = $or: []
            for key, property of @tableState().columns
              @mapQuery key, property, searchQuery
            # If the base query is for all records in the collection, the filter query is the only query run.
            if @query() is {}
              @tableState().query = searchQuery
              # If the base query is already filter the collection, the filter query is run as an `$and` against it.
            else
              @tableState().query =
                $and: [
                  @query()
                  searchQuery
                ]
          else @tableState().query = @query()

          # ##### mapSortOrder()
          # Only runs if columns are being sorted.
          if @tableState().iSortingCols > 0
            @tableState().sort = {}
            # Sets sort direction for each sorted field, allowing multi column sort.
            @mapSortOrder( sortIndex, aoData ) for sortIndex in [ 1..@tableState().iSortingCols ]
