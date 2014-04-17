DataTableSubscriptionCount = new Meteor.Collection("datatable_subscription_count")

#====== Template ======#
# Set default table template
Template.dataTable.defaultTemplate = 'default_table_template'

# Return the template specified in the component parameters
Template.dataTable.chooseTemplate = ( table_template = null ) ->
  # set table template to default if no template name is passed in
  table_template ?= Template.dataTable.defaultTemplate
  # if the template is defined return it
  if Template[ table_template ]
    return Template[ table_template ]
  # otherwise return the default template
  else return Template[ @defaultTemplate ]
#====== /Template ======#

#====== Initialization ======#
Template.dataTable.rendered = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.log "rendered", @
  instantiatedComponent.initialize()

Template.dataTable.destroyed = ->
  @log "destroyed"

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
  sDom: "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  oLanguage:
    sSearch: "_INPUT_"
    sLengthMenu: "<span>Show :</span> _MENU_"
    sProcessing: "Loading"
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

# Prepares the datatable options object by merging the options passed in with the defaults
Template.dataTable.prepareOptions = ->
  options = @getOptions() or {}
  options.aaData = @getRows() or []
  options.aoColumns = @getColumns() or []
  # if this is a reactive datatable
  if @getCollection() and @getQuery()
    options.bServerSide = true
    options.bProcessing = true
    # this field is currently useless, but is passed into fnServerData by datatables
    options.sAjaxSource = "useful?"
    # bind the datatables server callback to this component instance
    options.fnServerData = _.debounce( @fnServerData.bind( @ ), 300 )
  # merge defaults into options object
  @setOptions _.defaults( options, @defaultOptions )

Template.dataTable.mapTableState = ( aoData ) ->
  # convert aoData to key -> value pairs
  aoData = @arrayToDictionary aoData, 'name'
  @log 'mapTableState:aoData', aoData
  # use aoData to setup table state
  tableState =
    # request counter
    sEcho: aoData.sEcho.value or 1
    bRegex: aoData.bRegex.value or false
    # number of columns being displayed
    iColumns: aoData.iColumns.value or 0
    # number of rows being displayed
    iDisplayLength: aoData.iDisplayLength.value or 10
    # number of rows to skip
    iDisplayStart: aoData.iDisplayStart.value or 0
    # number of rows being sorted
    iSortingCols: aoData.iSortingCols.value or 0
    # individual column filters ( csv )
    sColumns: aoData.sColumns.value or ""
    # global filter
    sSearch: aoData.sSearch.value or ""
    columns: []
  # helper for getting aoData properties
  getDataProp = ( key, index ) ->
    key = "#{ key }_#{ index }"
    return aoData[ key ].value
  # iterator for setting up columns
  mapColumns = ( index ) ->
    # create an element for each column
    tableState.columns[ getDataProp 'mDataProp', index ] =
      # field name
      mDataProp: getDataProp 'mDataProp', index
      # field regex
      bRegex: getDataProp 'bRegex', index
      # is searchable boolean
      bSearchable: getDataProp 'bSearchable', index
      # is sortable boolean
      bSortable: getDataProp 'bSortable', index
      # search string
      sSearch: getDataProp 'sSearch', index
  # setup each column in aoData
  mapColumns index for index in [ 0..( tableState.iColumns - 1 ) ]
  # if there is a global filter
  if tableState.sSearch isnt ""
    # initialize filter query
    # filter query uses parallel $or's for each searchable field
    # each searchable field should also be indexed
    searchQuery = $or: []
    # iterator for creating filter query
    mapQuery = ( key, property ) ->
      # don't search the _id field
      unless property.bSearchable is false
        # initialize empty object
        obj = {}
        # set regex options for the current field
        obj[ key ] =
          # set regex to the value of the global search filter
          $regex: tableState.sSearch
          # ignore case in search regex
          $options: 'i'
        # add the object to the searchQuery
        searchQuery.$or.push obj
    # setup searchQuery for each searchable field
    for key, property of tableState.columns
      mapQuery key, property
    # if the table query is for all records in the collection
    if @getQuery is {}
      # set the table state query to just be the search query
      tableState.query = searchQuery
    else
      # if the table query is already filtering the collection
      tableState.query =
        # all documents must pass both the table query and search query
        $and: [
          @getQuery()
          searchQuery
        ]
  # if there is no global filter just set the table state query to the table query
  else tableState.query = @getQuery()
  # if there are columns being sorted
  if tableState.iSortingCols > 0
    # initialize sort object
    tableState.sort = {}
    # iterator for creating sort query
    mapSortOrder = ( sortIndex ) ->
      # switch to zero based index
      sortIndex = sortIndex - 1
      # figure out which column is being sorted
      propertyIndex = getDataProp 'iSortCol', sortIndex
      propertyName = getDataProp 'mDataProp', propertyIndex
      # set sort direction for each sorted field
      switch getDataProp( 'sSortDir', sortIndex )
        when 'asc' then tableState.sort[ propertyName ] = 1
        when 'desc' then tableState.sort[ propertyName ] = -1
    # setup sort object
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
  # prepare table state ( sort, filter )
  @setTableState aoData
  # prepare subscription options ( pagination, limit, sort )
  @setSubscriptionOptions
    skip: @getTableState().iDisplayStart
    limit: @getTableState().iDisplayLength
    sort: @getTableState().sort
  # subscibe to the dataset matching the current table state
  @setSubscriptionHandle Meteor.subscribe( @getSubscription(), @getQuery(), @getTableState().query, @getSubscriptionOptions() )
  # run the datatables server callback when the subscription is ready
  @setSubscriptionAutorun Deps.autorun =>
    if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
      @log 'fnServerdData:handle:ready', @getSubscriptionHandle().ready()
      # setup local cursor options ( identical to server except no skip )
      cursorOptions =
        skip: 0
        limit: @getTableState().iDisplayLength
        sort: @getTableState().sort
      # set local cursor to monitor the current table state
      @setCursor @getCollection().find @getTableState().query, cursorOptions
      # fetch the data for the current table state
      aaData = @getCursor().fetch()
      @log 'fnServerData:aaData', aaData
      # call the datatable server callback with the current table state ( called from the client )
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

Template.dataTable.setCountCollection = ( collection ) ->
  Match.test collection, Object
  @setData 'countCollection', collection
  @log 'collection:count:set', collection

Template.dataTable.prepareCollection = ->
  @prepareCountCollection()
  return

Template.dataTable.prepareCountCollection = ->
  collection = @getData().countCollection or DataTableSubscriptionCount
  @setCountCollection collection

Template.dataTable.getCollection = ->
  return @getData().collection or false

Template.dataTable.getCountCollection = ->
  return @getData().countCollection or false

Template.dataTable.getTotalCount = ->
  return @getCountCollection().findOne( "#{ @getSubscription() }" ).count or false

Template.dataTable.getFilteredCount = ->
  return @getCountCollection().findOne( "#{ @getSubscription() }_filtered" ).count or false
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
    bSearchable: false
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
Template.dataTable.getTemplateInstance = ->
  return @templateInstance or false

Template.dataTable.getGuid = ->
  return @guid or false

Template.dataTable.getData = ->
  return @getTemplateInstance().data or false

Template.dataTable.setData = ( key, data ) ->
  @templateInstance.data[ key ] = data

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