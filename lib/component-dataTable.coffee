#====== Template ======#
# Set default table template
Template.dataTable.default_template = 'default_table_template'

# Return the template specified in the component parameters
Template.dataTable.chooseTemplate = ( table_template = null ) ->
  table_template ?= Template.dataTable.default_template
  if Template[ table_template ]
    return Template[ table_template ]
  else return Template[ @default_template ]
#====== /Template ======#

#====== Initialization ======#
Template.dataTable.rendered = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.log "rendered", @
  instantiatedComponent.initialize()

Template.dataTable.destroyed = ->


Template.dataTable.initialize = ->
  @prepareQuery()
  @prepareCollection()
  @prepareColumns()
  @prepareRows()
  @prepareOptions()
  @prepareDataTable()
  @prepareFilters()
  @preparePagination()
  @log "initialized", @

Template.dataTable.getTemplateInstance = ->
  return @templateInstance or false

Template.dataTable.getGuid = ->
  return @guid or false

Template.dataTable.getData = ->
  return @getTemplateInstance().data or false

Template.dataTable.setData = ( key, data ) ->
  @templateInstance.data[ key ] = data
#====== /Initialization ======#

#====== Options ======#
# Global defaults for all datatables
# These can be overridden by the options parameter
Template.dataTable.defaultOptions =
  #===== Default Table
  # * Pagination
  # * Filtering
  # * Sorting
  # * Bootstrap3 Markup
  bJQueryUI: false
  bAutoWidth: true
  bDeferRender: true
  sPaginationType: "full_numbers"
  sDom: "<\"datatable-header\"fl><\"datatable-scroll\"t><\"datatable-footer\"ip>"
  oLanguage:
    sSearch: "_INPUT_"
    sLengthMenu: "<span>Show :</span> _MENU_"
    oPaginate:
      sFirst: "First"
      sLast: "Last"
      sNext: ">"
      sPrevious: "<"
  aoColumnDefs: []
  aaSorting: []
  aaData: []
  aoColumns: []

Template.dataTable.setOptions = ( options ) ->
  Match.test options, Object
  @setData 'options', options
  @log "options:set", options

Template.dataTable.getOptions = ->
  return @getData().options or @presetOptions() or false

# Prepares the options object by merging the options passed in with the defaults
Template.dataTable.prepareOptions = ->
  options = @getOptions() or {}
  options.aaData = @getRows() or []
  options.aoColumns = @getColumns() or []
  if @getCollection() and @getQuery()
    options.bServerSide = true
    options.sAjaxSource = "useful?"
    options.fnServerData = @fnServerData.bind @
  @setOptions _.defaults( options, @defaultOptions )

Template.dataTable.mapTableState = ( aoData ) ->
  aoData = @arrayToDictionary aoData, 'name'
  @log 'mapTableState:aoData', aoData
  tableState =
    sEcho: aoData.sEcho.value or 1
    bRegex: aoData.bRegex.value or false
    iColumns: aoData.iColumns.value or 0
    iDisplayLength: aoData.iDisplayLength.value or 10
    iDisplayStart: aoData.iDisplayStart.value or 0
    iSortingCols: aoData.iSortingCols.value or 0
    sColumns: aoData.sColumns.value or ""
    sSearch: aoData.sSearch.value or ""
    columns: []
  getDataProp = ( key, index ) ->
    key = "#{ key }_#{ index }"
    return aoData[ key ].value
  mapColumns = ( index ) ->
    tableState.columns[ getDataProp 'mDataProp', index ] =
      mDataProp: getDataProp 'mDataProp', index
      bRegex: getDataProp 'bRegex', index
      bSearchable: getDataProp 'bSearchable', index
      bSortable: getDataProp 'bSortable', index
      sSearch: getDataProp 'sSearch', index
  mapColumns index for index in [ 0..( tableState.iColumns - 1 ) ]

  if tableState.sSearch isnt ""
    searchQuery = $or: []
    mapQuery = ( key, property ) ->
      unless key is '_id'
        if tableState.sSearch isnt ""
          obj = {}
          obj[ key ] =
            $regex: tableState.sSearch
            $options: 'i'
          searchQuery.$or.push obj

    for key, property of tableState.columns
      mapQuery key, property

    if @getQuery is {}
      tableState.query = searchQuery
    else
      tableState.query =
        $and: [
          @getQuery()
          searchQuery
        ]
  else tableState.query = @getQuery()

  if tableState.iSortingCols > 0
    tableState.sort = {}
    mapSortOrder = ( sortIndex ) ->
      sortIndex = sortIndex - 1
      propertyIndex = getDataProp 'iSortCol', sortIndex
      propertyName = getDataProp 'mDataProp', propertyIndex
      switch getDataProp( 'sSortDir', sortIndex )
        when 'asc' then tableState.sort[ propertyName ] = 1
        when 'desc' then tableState.sort[ propertyName ] = -1
    mapSortOrder sortIndex for sortIndex in [ 1..tableState.iSortingCols ]

  return tableState

Template.dataTable.setTableState = ( aoData ) ->
  Match.test aoData, Object
  tableState = @mapTableState aoData
  @setData 'tableState', tableState
  @log 'tableState:set', tableState

Template.dataTable.getTableState = ->
  return @getData().tableState or false


Template.dataTable.fnServerData = ( sSource, aoData, fnCallback, oSettings ) ->
  @setTableState aoData
  @setSubscriptionOptions
    skip: @getTableState().iDisplayStart
    limit: @getTableState().iDisplayLength
    sort: @getTableState().sort
  @setSubscriptionHandle Meteor.subscribe( @getSubscription(), @getTableState().query, @getSubscriptionOptions() )
  @setSubscriptionAutorun Deps.autorun =>
    if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
      @log 'fnServerdData:handle:ready', @getSubscriptionHandle().ready()
      cursorOptions =
        skip: 0
        limit: @getTableState().iDisplayLength
        sort: @getTableState().sort
      @setCursor @getCollection().find @getTableState().query, cursorOptions
      aaData = @getCursor().fetch()
      @log 'fnServerData:aaData', aaData
      fnCallback
        # An unaltered copy of sEcho sent from the client side.
        # This parameter will change with each draw (it is basically a draw count)
        sEcho: @getTableState().sEcho
        # Total records, before filtering (i.e. the total number of records in the database)
        iTotalRecords: @getTotalCount()
        # Total records, after filtering (i.e. the total number of records after filtering has been applied
        # not just the number of records being returned in this result set)
        iTotalDisplayRecords: @getFilteredCount()
        # The data in a 2D array. Note that you can change the name of this parameter with sAjaxDataProp.
        aaData: aaData
      #@prepareObservers()
#====== /Options ======#

#====== Selector ======#
Template.dataTable.setSelector = ( selector ) ->
  Match.test selector, String
  @setData 'selector', selector
  @log 'selector:set', selector

Template.dataTable.getSelector = ->
  return @getData().selector or false

Template.dataTable.prepareSelector = ->
  unless @getSelector()
    @setSelector "datatable-#{ @getGuid() }"
#====== /Selector ======#

#====== Query ======#
Template.dataTable.setQuery = ( query ) ->
  Match.test query, Object
  @setData 'query', query
  @log 'query:set', query

Template.dataTable.prepareQuery = ->
  unless @getQuery()
    @setQuery {}

Template.dataTable.getQuery = ->
  return @getData().query or false
#====== /Query ======#

#====== Collection ======#
Template.dataTable.setCollection = ( collection ) ->
  Match.test collection, Object
  @setData 'collection', collection
  @log 'collection:set', collection

Template.dataTable.setTotalCount = ( count ) ->
  Match.test count, Number
  @setData 'countTotal', count
  @log 'collection:count:total:set', count

Template.dataTable.setFilteredCount = ( count ) ->
  Match.test count, Number
  @setData 'filteredCount', count
  @log 'collection:count:filtered:set'

Template.dataTable.prepareCollection = ->
  return

Template.dataTable.getCollection = ->
  return @getData().collection or false

Template.dataTable.getTotalCount = ->
  return 100000 or false

Template.dataTable.getFilteredCount = ( query = {} ) ->
  return 100000 or false
#====== /Collection ======#

#====== Subscription ======#
Template.dataTable.setSubscription = ( subscription ) ->
  Match.test subscription, Object
  @setData 'subscription', subscription
  @log 'subscription:set', subscription

Template.dataTable.setSubscriptionOptions = ( options ) ->
  Match.test options, Object
  @setData 'subscriptionOptions', options
  @log 'subscription:options:set', options

Template.dataTable.setSubscriptionHandle = ( handle ) ->
  Match.test handle, Object
  if @getSubscriptionHandle()
    @getSubscriptionHandle().stop()
  @setData 'handle', handle
  @log 'subscription:handle:set', handle

Template.dataTable.setSubscriptionAutorun = ( autorun ) ->
  Match.test autorun, Object
  if @getSubscriptionAutorun()
    @getSubscriptionAutorun().stop()
  @setData 'autorun', autorun
  @log 'subscription:autorun:set', autorun

Template.dataTable.prepareSubscription = ->
  return

Template.dataTable.prepareSubscriptionHandle = ->
  return

Template.dataTable.prepareSubscriptionAutorun = ->
  return

Template.dataTable.getSubscription = ->
  return @getData().subscription or false

Template.dataTable.getSubscriptionOptions = ->
  return @getData().subscriptionOptions or false

Template.dataTable.getSubscriptionHandle = ->
  return @getData().handle or false

Template.dataTable.getSubscriptionAutorun = ->
  return @getData().autorun or false
#====== /Subscription ======#

#====== Rows ======#
Template.dataTable.setRows = ( rows ) ->
  Match.test rows, Object
  @setData 'rows', rows
  @log 'rows:set', rows

Template.dataTable.prepareRows = ->
  return

Template.dataTable.getRows = ->
  if @getDataTable()
    return @getDataTable().fnSettings().aoData or false
  else return @getData().rows or false

Template.dataTable.getRowIndex = ( _id ) ->
  index = false
  counter = 0
  rows = @getRows()
  checkIndex = ( row ) ->
    if row._aData._id is _id
      index = counter
    counter++
  checkIndex row for row in rows
  return index

Template.dataTable.addRow = ( _id, fields, before = null ) ->
  Match.test _id, String
  Match.test fields, Object
  if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
    index = @getRowIndex _id
    unless index
        row = @getCollection().findOne _id
        index = @getDataTable().fnAddData row
        @log "row:added:#{ _id }", row

Template.dataTable.updateRow = ( _id, fields ) ->
  Match.test _id, String
  Match.test fields, Object
  if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
    index = @getRowIndex _id
    if index
      row = @getCollection().findOne _id
      @getDataTable().fnUpdate row, index
      @log "row:updated:#{ _id } -> ", row
    else @addRow _id, fields

Template.dataTable.removeRow = ( _id ) ->
  Match.test _id, String
  if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
    index = @getRowIndex _id
    if index
      @getDataTable().fnDeleteRow index
      @log "row:removed:#{ _id }"

Template.dataTable.moveRow = ( row, oldIndex, newIndex ) ->
  @log "row:moved:#{ row._id } ", row
#====== /Rows ======#

#====== Columns ======#
Template.dataTable.setColumns = ( columns ) ->
  Match.test columns, Array
  @setData 'columns', columns
  @log "columns:set", columns

Template.dataTable.prepareColumns = ->
  columns = @getColumns() or []
  # add _id as a hidden column
  columns.push
    sTitle: "id"
    mData: "_id"
    bVisible: false
  # a function to add a default mRender function if one is not defined
  # iterate over the columns array and add mRender to the columns that need it
  @setDefaultCellValue column for column in columns
  @setColumns columns

Template.dataTable.getColumns = ->
  return @getData().columns or false
#====== /Columns ======#

#====== Cursor ======#
Template.dataTable.setCursor = ( cursor ) ->
  Match.test cursor, Object
  if @getCursorObserver()
    @stopObservers()
  @setData 'cursor', cursor
  @log "cursor:set", cursor

Template.dataTable.setCursorObserver = ( cursorObserver ) ->
  Match.test cursorObserver, Object
  if @getCursorObserver()
    @stopObservers()
  @setData 'cursorObserver', cursorObserver
  @log "cursor:observer:set", cursorObserver

Template.dataTable.unsetCursorObserver = ->
  if @getCursorObserver()
    delete @templateInstance.data.cursorObserver
    @log "cursor:observer:set", @templateInstance.data.cursorObserver

Template.dataTable.prepareCursor = ->
  return

Template.dataTable.getCursor = ->
  return @getData().cursor or false

Template.dataTable.getCursorObserver = ->
  return @getData().cursorObserver or false

Template.dataTable.prepareObservers = ->
  if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
    if @getCollection() and @getQuery()
      collectionObserver = @getCollection().find( @getQuery() ).observeChanges
        added: @addRow.bind @
        changed: @updateRow.bind @
        moved: @moveRow.bind @
        removed: @removeRow.bind @
      @setCursorObserver collectionObserver
      @log 'cursor:observe:start'

Template.dataTable.stopObservers = ->
  if @getCursorObserver()
    @getCursorObserver().stop()
    @unsetCursorObserver()
    @log 'cursor:observer:stopped', @getCursorObserver()
#====== /Cursor ======#

#====== DataTable ======#
Template.dataTable.getDataTable = ->
  return @getTemplateInstance().dataTable or false

Template.dataTable.setDataTable = ( dataTable ) ->
  Match.test dataTable, Object
  @getTemplateInstance().dataTable = dataTable
  @log "dataTable:set", dataTable.fnSettings()

Template.dataTable.prepareDataTable = ->
  @setDataTable $(".#{ @getSelector() } table").dataTable( @getOptions() )
#====== /DataTable ======#

#====== Filters ======#
Template.dataTable.prepareFilters = ->
  @prepareFilterPlaceholder()
  @prepareFooterFilter()

Template.dataTable.prepareFilterPlaceholder = ->
  $(".#{ @getSelector() } .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."

Template.dataTable.prepareFooterFilter = ->
  selector = @getSelector()
  if selector is 'datatable-add-row' and $.keyup
    self = @
    $(".#{ selector } .dataTables_wrapper tfoot input").keyup ->
      target = @
      self.getDataTable().fnFilter target.value, $(".#{ self.getSelector() } .dataTables_wrapper tfoot input").index( target )
#====== /Filters ======#

#====== Pagination ======#
Template.dataTable.preparePagination = ->
  unless $.select2
    $(".#{ @getSelector() } .dataTables_length select").select2 minimumResultsForSearch: "-1"
#====== /Pagination ======#

#====== Utility ======#
Template.dataTable.setDefaultCellValue = ( column ) ->
  Match.test column.mData, String
  Match.test column.sTitle, String
  unless column.mRender
    column.mRender = ( dataSource, call, rawData ) ->
      rawData[ column.mData ] ?= ""

Template.dataTable.arrayToDictionary = ( array, key ) ->
  dict = {}
  dict[obj[key]] = obj for obj in array when obj[key]?
  dict

Template.dataTable.isDebug = ->
  return @getData().debug or false

Template.dataTable.log = ( message, object ) ->
  if @isDebug()
    if message.indexOf( @isDebug() ) isnt -1 or @isDebug() is "true"
      console.log "dataTable:#{ @getSelector() }:#{ message } ->", object
#====== /Utility ======#

#====== Presets ======#
# TODO : this is temporary all of this should be passed in through the options param
Template.dataTable.presetOptions = ->
  selector = @getSelector()
  #===== Table with tasks =====#
  if selector is 'datatable-tasks'
    options =
      aoColumnDefs: [{
        bSortable: false
        aTargets: [5]
      }]
  #===== Table with invoices =====#
  if selector is 'datatable-invoices'
    options =
      aoColumnDefs: [{
        bSortable: false
        aTargets: [
          1
          6
        ]
      }]
      aaSorting: [
        [
          0
          "desc"
        ]
      ]
  #===== Table with selectable rows =====#
  if selector is 'datatable-selectable'
    options =
      sDom: "<\"datatable-header\"Tfl><\"datatable-scroll\"t><\"datatable-footer\"ip>"
      oTableTools:
        sRowSelect: "multi"
        aButtons: [{
          sExtends: "collection"
          sButtonText: "Tools <span class='caret'></span>"
          sButtonClass: "btn btn-primary"
          aButtons: [
            "select_all"
            "select_none"
          ]
        }]
  #===== Table with media objects ======#
  if selector is 'datatable-media'
    options =
      aoColumnDefs: [
        bSortable: false
        aTargets: [
          0
          4
        ]
      ]
  #===== Table with two button pager ======#
  if selector is 'datatable-pager'
    options =
      sPaginationType: "two_button"
      oLanguage:
        sSearch: "<span>Filter:</span> _INPUT_"
        sLengthMenu: "<span>Show entries:</span> _MENU_"
        oPaginate:
          sNext: "Next →"
          sPrevious: "← Previous"
  #===== Table with tools ======#
  if selector is 'datatable-tools'
    options =
      sDom: "<\"datatable-header\"Tfl><\"datatable-scroll\"t><\"datatable-footer\"ip>"
      oTableTools:
        sRowSelect: "single"
        sSwfPath: "static/swf/copy_csv_xls_pdf.swf"
        aButtons: [{
          sExtends: "copy"
          sButtonText: "Copy"
          sButtonClass: "btn"
        },{
          sExtends: "print"
          sButtonText: "Print"
          sButtonClass: "btn"
        },{
          sExtends: "collection"
          sButtonText: "Save <span class='caret'></span>"
          sButtonClass: "btn btn-primary"
          aButtons: [
            "csv"
            "xls"
            "pdf"
          ]
        }]
  #===== Table with custom sorting columns ======#
  if selector is 'datatable-custom-sort'
    options =
      aoColumnDefs: [{
        bSortable: false
        aTargets: [
          0
          1
        ]
      }]
  #====== Return ======#
  return options
#====== /Presets ======#