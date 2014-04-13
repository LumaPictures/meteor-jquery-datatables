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

Template.dataTable.initialize = ->
  @prepareQuery()
  @prepareCollection()
  @prepareCursor()
  @prepareColumns()
  @prepareRows()
  @prepareOptions()
  @prepareDataTable()
  @prepareFilters()
  @preparePagination()
  @prepareObservers()
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
  @setOptions _.defaults( options, @defaultOptions )
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

Template.dataTable.prepareCollection = ->
  return

Template.dataTable.getCollection = ->
  return @getData().collection or false
#====== /Collection ======#

#====== Rows ======#
Template.dataTable.setRows = ( rows ) ->
  Match.test rows, Object
  @setData 'rows', rows
  @log 'rows:set', rows

Template.dataTable.prepareRows = ->
  ###
  if @getCollection() and @getQuery()
    rows = @getCollection().find( @getQuery() ).fetch()
    dictionary = @arrayToDictionary rows, '_id'
    @setRows rows
  ###
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


Template.dataTable.addRow = ( _id, fields ) ->
  Match.test _id, String
  Match.test fields, Object
  index = @getRowIndex _id
  unless index
    row = @getCollection().findOne _id
    index = @getDataTable().fnAddData row
    @log "row:added:#{ _id } -> ", row

Template.dataTable.updateRow = ( _id, fields ) ->
  Match.test _id, String
  Match.test fields, Object
  index = @getRowIndex _id
  if index
    row = @getCollection().findOne _id
    @getDataTable().fnUpdate row, index
    @log "row:updated:#{ _id } -> ", row
  else @addRow _id, fields

Template.dataTable.removeRow = ( _id ) ->
  Match.test _id, String
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
  @setData 'cursor', cursor
  @log "cursor:set", cursor

Template.dataTable.prepareCursor = ->
  if @getQuery() and @getCollection()
    @setCursor @getCollection().find( @getQuery() )

Template.dataTable.getCursor = ->
  return @getData().cursor or false
#====== /Cursor ======#

#====== DataTable ======#
Template.dataTable.getDataTable = ->
  return @getTemplateInstance().dataTable or false

Template.dataTable.setDataTable = ( dataTable ) ->
  Match.test dataTable, Object
  @getTemplateInstance().dataTable = dataTable
  @log "dataTable:set", dataTable

Template.dataTable.prepareDataTable = ->
  @setDataTable $(".#{ @getSelector() } table").dataTable( @getOptions() )
#====== /DataTable ======#

#====== Observers ======#
Template.dataTable.prepareObservers = ->
  #===== Setup observers to add and remove rows from the dataTable ======#
  if @getCursor()
    @getCursor().observeChanges
      added: @addRow.bind @
      changed: @updateRow.bind @
      moved: @moveRow.bind @
      removed: @removeRow.bind @
#====== /Observers ======#

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
    console.log "#{ @getSelector() }:#{ message }", object
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