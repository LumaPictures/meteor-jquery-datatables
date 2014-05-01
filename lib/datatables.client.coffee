# Client
# ======

# ## Initialization

# ##### rendered()
# When the component is first rendered datatables is initialized `templateInstance.__component__` is the this context
Template.dataTable.rendered = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.log "rendered", @
  instantiatedComponent.initialize()

# ##### destroyed()
# Currently nothing is done when the component is destroyed.
Template.dataTable.destroyed = ->
  if @.log
    @log "destroyed"

# ##### initialize()
# Set the initial table properties from the component declaration, initialize the jQuery DataTables object, and initialize
# other third parties if they exist ( plugins, select2, etc. )
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

# ### Collection Counts
# Datatables maintains counts of both the base query and filtered query reactively.
# These counts are published by the datatables publication

DataTableSubscriptionCount = new Meteor.Collection "datatable_subscription_count"

# ## Component Parameters

# #### `options` Object ( optional )
# `options` are additional options you would like merged with the defaults `_.defaults options, defaultOptions`.
# For more information on available dataTable options see the [DataTables Docs](https://datatables.net/usage/).
# The default options are listed below and can be changed by setting `Template.dataTable.defaultOptions.yourDumbProperty`
# ##### [DataTables Options Full Reference](https://datatables.net/ref)
Template.dataTable.defaultOptions =
  bJQueryUI: false
  bAutoWidth: true
  bDeferRender: true
  sPaginationType: "full_numbers"
  # ##### Bootstrap 3 Markup
  # You can change this by setting `Template.dataTable.defaultOptions.sDom` property.
  # For some example Less / CSS styles check out [luma-ui's dataTable styles](https://github.com/LumaPictures/luma-ui/blob/master/components/dataTables/dataTables.import.less)
  sDom: "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  oLanguage:
    sSearch: "_INPUT_"
    sLengthMenu: "<span>Show :</span> _MENU_"
    # ##### Loading Message
    # Set `oLanguage.sProcessing` to whatever you want, event html. I haven't tried a Meteor template yet, could be fun!
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

# ##### setOptions()
Template.dataTable.setOptions = ( options ) ->
  Match.test options, Object
  @setData 'options', options
  @log "options:set", options

# ##### getOptions()
Template.dataTable.getOptions = ->
  return @getData().options or @presetOptions() or false

# ##### prepareOptions()
# Prepares the datatable options object by merging the options passed in with the defaults.
Template.dataTable.prepareOptions = ->
  options = @getOptions() or {}
  options.aaData = @getRows() or []
  options.aoColumns = @getColumns() or []
  # If the componet was declared with a collection and a query it is setup as a reactive datatable.
  if @getCollection() and @getQuery()
    options.bServerSide = true
    options.bProcessing = true
    # `options.sAjaxSource` is currently useless, but is passed into `fnServerData` by datatables.
    options.sAjaxSource = "useful?"
    # This binds the datatables `fnServerData` server callback to this component instance.
    # `_.debounce` is used to prevent unneccesary subcription calls while typing a search
    options.fnServerData = _.debounce( @fnServerData.bind( @ ), 300 )
  @setOptions _.defaults( options, @defaultOptions )

# #### `selector` String ( required )
# The table selector for the dataTable instance you are creating, must be unique in the page scope or you will get
# datatable mulit-render error.
Template.dataTable.setSelector = ( selector ) ->
  Match.test selector, String
  @setData 'selector', selector
  @log 'selector:set', selector

# ##### getSelector()
Template.dataTable.getSelector = ->
  return @getData().selector or false

# ##### prepareSelector()
Template.dataTable.prepareSelector = ->
  unless @getSelector()
    @setSelector "datatable-#{ @getGuid() }"

# #### `rows` Array of Object ( optional )
# Can be used to display static data, or reactive client side data.

# ##### setRows()
Template.dataTable.setRows = ( rows ) ->
  Match.test rows, Object
  @setData 'rows', rows
  @log 'rows:set', rows

# ##### preprareRows()
Template.dataTable.prepareRows = ->
  return

# ##### getRows()
Template.dataTable.getRows = ->
  if @getDataTable()
    return @getDataTable().fnSettings().aoData or false
  else return @getData().rows or false

# ##### getRowIndex()
# Gets the datatable index of a row by mongo id.
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

# #### `columns` Array of Objects ( required )
# The column definitions you are passing to the datatable component. This is where to map object properties to columns
# and their headers. You can also define custom templates for rendering data in cells using the `mData` property.

# ##### setColumns()
Template.dataTable.setColumns = ( columns ) ->
  Match.test columns, Array
  @setData 'columns', columns
  @log "columns:set", columns

# ##### prepareColumns()
Template.dataTable.prepareColumns = ->
  columns = @getColumns() or []
  # Adds _id as a hidden column by default.
  columns.push
    sTitle: "id"
    mData: "_id"
    bVisible: false
    bSearchable: false
  # Sets a default cell render function for every column.
  @setDefaultCellValue column for column in columns
  @setColumns columns

# ##### setDefaultCellValue()
# The default cell render function defaults all cells to "" if undefined.
Template.dataTable.setDefaultCellValue = ( column ) ->
  Match.test column.mData, String
  Match.test column.sTitle, String
  unless column.mRender
    column.mRender = ( dataSource, call, rawData ) ->
      rawData[ column.mData ] ?= ""

# ##### getColumns()
Template.dataTable.getColumns = ->
  return @getData().columns or false

# #### `table_template` String ( optional )
# The name of table layout template that you want to render.
# Default is `default_table_template` found [here](lib/datatables.html).
# You can set your default template by assigning the template name to `Template.datatable.defaultTemplate`.

# ##### Default Table Template
# The default table template is defined in datatables.html.
Template.dataTable.defaultTemplate = 'default_table_template'

# ##### chooseTemplate Helper
# Return the template specified in the component parameters
Template.dataTable.chooseTemplate = ( table_template = null ) ->
  # Set table template to default if no template name is passed in
  table_template ?= Template.dataTable.defaultTemplate
  # If the template is defined return it
  if Template[ table_template ]
    return Template[ table_template ]
  # Otherwise return the default template
  else return Template[ @defaultTemplate ]


# #### `collection` Meteor Collection ( required )
# This is the collection that houses the documents your datatable is displaying
# and must be defined on both the client and the server.
Template.dataTable.setCollection = ( collection ) ->
  Match.test collection, Object
  @setData 'collection', collection
  @log 'collection:set', collection

# ##### setCountCollection()
Template.dataTable.setCountCollection = ( collection ) ->
  Match.test collection, Object
  @setData 'countCollection', collection
  @log 'collection:count:set', collection

# ##### prepareCollection()
Template.dataTable.prepareCollection = ->
  @prepareCountCollection()
  return

# #### `subscription` String ( required )
# The name of the subscription your datatable is paging, sorting, and filtering.
# This must be a datatable compatible publication ( for more info see Server )
Template.dataTable.setSubscription = ( subscription ) ->
  Match.test subscription, Object
  @setData 'subscription', subscription
  @log 'subscription:set', subscription

# ##### setSubscriptionOptions()
Template.dataTable.setSubscriptionOptions = ->
  options =
    skip: @getTableState().iDisplayStart
    limit: @getTableState().iDisplayLength
    sort: @getTableState().sort
  @setData 'subscriptionOptions', options
  @log 'subscription:options:set', options

# ##### setSubscriptionHandle()
# Subscribes to the dataset for the current table state and stores the handle for later access.
Template.dataTable.setSubscriptionHandle = ->
  if @getSubscriptionHandle()
    @getSubscriptionHandle().stop()
  handle = Meteor.subscribe @getSubscription(), @getQuery(), @getTableState().query, @getSubscriptionOptions()
  @setData 'handle', handle
  @log 'subscription:handle:set', handle

# ##### setSubscriptionAutorun()
# Creates a reactive computation that runs when the subscription is `ready()`
# and sets up local cursor ( identical to server except no skip ).
Template.dataTable.setSubscriptionAutorun = ( fnCallback ) ->
  Match.test fnCallback, Object
  if @getSubscriptionAutorun()
    @getSubscriptionAutorun().stop()
  autorun = Deps.autorun =>
    if @getSubscriptionHandle() and @getSubscriptionHandle().ready()
      @log 'fnServerdData:handle:ready', @getSubscriptionHandle().ready()
      cursorOptions = skip: @getTableState().iDisplayStart or 0
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
Template.dataTable.getSubscription = ->
  return @getData().subscription or false

# ##### getSubscriptionOptions()
Template.dataTable.getSubscriptionOptions = ->
  return @getData().subscriptionOptions or false

# ##### getSubscriptionHandle()
Template.dataTable.getSubscriptionHandle = ->
  return @getData().handle or false

# ##### getSubscriptionAutorun()
Template.dataTable.getSubscriptionAutorun = ->
  return @getData().autorun or false

# #### `query` MongoDB Selector ( optional )
# The initial filter for your datatable.
# The default query is `{}`
# You should attempt to narrow your selection as much as possbile to improve performance.

# ##### setQuery()
Template.dataTable.setQuery = ( query ) ->
  Match.test query, Object
  @setData 'query', query
  @log 'query:set', query

# ##### prepareQuery()
Template.dataTable.prepareQuery = ->
  unless @getQuery()
    @setQuery {}

# ##### getQuery()
Template.dataTable.getQuery = ->
  return @getData().query or false

# #### `debug` String ( optional )
# A handy option for granular debug logs.
# `true` logs all messages from datatables.
# Set debug to any string to only log messages that contain that string
# ##### examples
#   + `rendered` logs the instantiated component on render
#   + `destroyed` logs when the component is detroyed
#   + `initialized` logs the inital state of the datatable after data is acquired
#   + `options` logs the datatables options for that instantiated component
#   + `fnServerData` logs each request to the server by the component

# ##### isDebug()
Template.dataTable.isDebug = ->
  return @getData().debug or false

# ##### log()
Template.dataTable.log = ( message, object ) ->
  if @isDebug()
    if message.indexOf( @isDebug() ) isnt -1 or @isDebug() is "true" or @isDebug() is true
      console.log "dataTable:#{ @getSelector() }:#{ message } ->", object

# ## Querying MongoDB

# ##### mapTableState()
# Take the `aoData` parameter of `fnServerData` and map it into a more usable object.
Template.dataTable.mapTableState = ( aoData ) ->
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
Template.dataTable.setTableState = ( aoData ) ->
  Match.test aoData, Object
  tableState = @mapTableState aoData
  @setData 'tableState', tableState
  @log 'tableState:set', tableState

# ##### getTableState()
Template.dataTable.getTableState = ->
  return @getData().tableState or false

# ##### fnServerData()
# The callback for every dataTables user / reactivity event
# ###### Parameters
#   + `sSource` is the currently useless `sAjaxProp` from the options
#   + `aoData` is an array of objects provided by datatables reflecting its current state
#   + `fnCallback` is the function that will be called when the server returns a result
#   + `oSettings` is the datatables settings object
Template.dataTable.fnServerData = ( sSource, aoData, fnCallback, oSettings ) ->
  # `setTableState()` parses aoData and creates a usable table state object.
  @setTableState aoData
  # `setSubscriptionOptions()` turns the table state into a MongoDB query options object.
  @setSubscriptionOptions()
  # `setSubscriptionHandle()` subscribes the the dataset for the current table state.
  @setSubscriptionHandle()
  # `setSubscriptionAutorun()` creates a Deps.autrun computation. The autorun computation will call datatables fnCallback
  # when the current table state subscription is ready.
  @setSubscriptionAutorun fnCallback

# ##### prepareCountCollection()
Template.dataTable.prepareCountCollection = ->
  collection = @getData().countCollection or DataTableSubscriptionCount
  @setCountCollection collection

# ##### getCollection()
Template.dataTable.getCollection = ->
  return @getData().collection or false

# ##### getCountCollection()
Template.dataTable.getCountCollection = ->
  return @getData().countCollection or false

# ##### getTotalCount()
Template.dataTable.getTotalCount = ->
  return @getCountCollection().findOne( "#{ @getSubscription() }" ).count or 0

# ##### getFilteredCount()
Template.dataTable.getFilteredCount = ->
  return @getCountCollection().findOne( "#{ @getSubscription() }_filtered" ).count or 0

# ### Cursor
#   The reactive cursor responsible for keeping the client in sync
#   identical to the server cursor publishing the data, except it does not skip

# ##### setCursor()
Template.dataTable.setCursor = ( cursor ) ->
  Match.test cursor, Object
  @setData 'cursor', cursor
  @log "cursor:set", cursor

# ##### prepareCursor()
Template.dataTable.prepareCursor = ->
  return

# ##### getCursor()
Template.dataTable.getCursor = ->
  return @getData().cursor or false

# ### DataTable Instance

# ##### getDataTable()
Template.dataTable.getDataTable = ->
  return @getTemplateInstance().dataTable or false

# ##### setDataTable()
Template.dataTable.setDataTable = ( dataTable ) ->
  Match.test dataTable, Object
  @getTemplateInstance().dataTable = dataTable
  @log "dataTable:set", dataTable.fnSettings()

# ##### prepareDataTable()
Template.dataTable.prepareDataTable = ->
  @setDataTable $(".#{ @getSelector() } table").dataTable( @getOptions() )

# ##### prepareFilters()
Template.dataTable.prepareFilters = ->
  @prepareFilterPlaceholder()
  @prepareFooterFilter()

# ##### prepareFilterPlaceholder()
Template.dataTable.prepareFilterPlaceholder = ->
  $(".#{ @getSelector() } .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."

# ##### prepareFooterFilter()
Template.dataTable.prepareFooterFilter = ->
  selector = @getSelector()
  if selector is 'datatable-add-row' and $.keyup
    self = @
    $(".#{ selector } .dataTables_wrapper tfoot input").keyup ->
      target = @
      self.getDataTable().fnFilter target.value, $(".#{ self.getSelector() } .dataTables_wrapper tfoot input").index( target )

# ##### preparePagination()
Template.dataTable.preparePagination = ->
  unless $.select2
    $(".#{ @getSelector() } .dataTables_length select").select2 minimumResultsForSearch: "-1"

# ## Utility Methods

# ##### getTemplateInstance()
Template.dataTable.getTemplateInstance = ->
  return @templateInstance or false

# ##### getGuid()
Template.dataTable.getGuid = ->
  return @guid or false

# ##### getData()
Template.dataTable.getData = ->
  return @getTemplateInstance().data or false

# ##### setData()
Template.dataTable.setData = ( key, data ) ->
  @templateInstance.data[ key ] = data

# ##### arrayToDictionary()
Template.dataTable.arrayToDictionary = ( array, key ) ->
  dict = {}
  dict[obj[key]] = obj for obj in array when obj[key]?
  dict

# ## Preset Tables

# TODO : this is temporary all of this should be passed in through the options param

# ##### presetOptions()
Template.dataTable.presetOptions = ->
  selector = @getSelector()

  if selector is 'datatable-tasks'
    options =
      aoColumnDefs: [{
        bSortable: false
        aTargets: [5]
      }]

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

  if selector is 'datatable-media'
    options =
      aoColumnDefs: [
        bSortable: false
        aTargets: [
          0
          4
        ]
      ]

  if selector is 'datatable-pager'
    options =
      sPaginationType: "two_button"
      oLanguage:
        sSearch: "<span>Filter:</span> _INPUT_"
        sLengthMenu: "<span>Show entries:</span> _MENU_"
        oPaginate:
          sNext: "Next →"
          sPrevious: "← Previous"

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

  if selector is 'datatable-custom-sort'
    options =
      aoColumnDefs: [{
        bSortable: false
        aTargets: [
          0
          1
        ]
      }]

  return options
