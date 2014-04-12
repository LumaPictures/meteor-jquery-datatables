#====== Template ======#
# Set default table template
Template.dataTable.default_template = 'default_table_template'

# Return the template specified in the component parameters
Template.dataTable.chooseTemplate = ( table_template = null ) ->
  table_template ?= Template.dataTable.default_template
  if Template[ table_template ]
    return Template[ table_template ]
  else return Template[ Template.dataTable.default_template ]
#====== /Template ======#

#====== Initialization ======#
Template.dataTable.rendered = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
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
  @templateInstance.data.options = options

Template.dataTable.getOptions = ->
  return @templateInstance.data.options or @presetOptions() or false

# Prepares the options object by merging the options passed in with the defaults
Template.dataTable.prepareOptions = ->
  self = @
  options = self.getOptions() or {}
  rows = self.getRows()
  columns = self.getColumns()
  if rows
    options.aaData = rows
  if columns
    options.aoColumns = columns
  self.setOptions _.defaults( options, self.defaultOptions )
#====== /Options ======#

#====== Selector ======#
Template.dataTable.setSelector = ( selector ) ->
  Match.test selector, String
  @templateInstance.data.selector = selector

Template.dataTable.getSelector = ->
  return @templateInstance.data.selector or false

Template.dataTable.prepareSelector = ->
  return
#====== /Selector ======#

#====== Query ======#
Template.dataTable.setQuery = ( query ) ->
  Match.test query, Object
  @templateInstance.data.query = query

Template.dataTable.prepareQuery = ->
  query = @getQuery()
  unless query
    query = {}
  @setQuery query

Template.dataTable.getQuery = ->
  return @templateInstance.data.query or false
#====== /Query ======#

#====== Collection ======#
Template.dataTable.setCollection = ( collection ) ->
  Match.test collection, Object
  @templateInstance.data.collection = collection

Template.dataTable.prepareCollection = ->
  return

Template.dataTable.getCollection = ->
  return @templateInstance.data.collection or false
#====== /Collection ======#

#====== Rows ======#
Template.dataTable.setRows = ( rows ) ->
  Match.test rows, Array
  @templateInstance.data.rows = rows

Template.dataTable.prepareRows = ->
  return

Template.dataTable.getRows = ->
  return @templateInstance.data.rows or false
#====== /Rows ======#

#====== Columns ======#
Template.dataTable.setColumns = ( columns ) ->
  Match.test columns, Array
  @templateInstance.data.columns = columns

Template.dataTable.prepareColumns = ->
  self = @
  columns = self.getColumns()
  # add _id as a hidden column
  columns.push
    sTitle: "id"
    mData: "_id"
    bVisible: false
  # a function to add a default mRender function if one is not defined
  # iterate over the columns array and add mRender to the columns that need it
  Template.dataTable.setDefaultCellValue( column ) for column in columns
  self.setColumns columns

Template.dataTable.getColumns = ->
  return @templateInstance.data.columns or false
#====== /Columns ======#

#====== Cursor ======#
Template.dataTable.setCursor = ( cursor ) ->
  Match.test cursor, Object
  @templateInstance.data.cursor = cursor

Template.dataTable.prepareCursor = ->
  query = @getQuery()
  collection = @getCollection()
  if query and collection
    @setCursor collection.find( query )

Template.dataTable.getCursor = ->
  return @templateInstance.data.cursor or false
#====== /Cursor ======#

#====== DataTable ======#
Template.dataTable.getDataTable = ->
  return @templateInstance.dataTable or false

Template.dataTable.setDataTable = ( dataTable ) ->
  Match.test dataTable, Object
  @templateInstance.dataTable = dataTable

Template.dataTable.prepareDataTable = ->
  self = @
  dataTable = $(".#{ self.getSelector() } table").dataTable( self.getOptions() )
  self.setDataTable dataTable
#====== /DataTable ======#

#====== Observers ======#
Template.dataTable.prepareObservers = ->
  component = @
  dataTable = component.getDataTable()
  console.log "#{ component.getSelector() }:component -> ", component
  console.log "#{ component.getSelector() }:options -> ", component.getOptions()
  console.log "#{ component.getSelector() }:oSettings -> ", dataTable.fnSettings()
  collection = component.getCollection()
  cursor = component.getCursor()
  #===== Setup observers to add and remove rows from the dataTable ======#
  if cursor
    cursor.observeChanges
      #====== callback fired whenever a new document is added that matches the cursor ======#
      added: ( _id, fields ) ->
        fields._id = _id
        console.log "#{ component.getSelector() }:row:added -> ", fields
        ###
        oSettings = dataTable.fnSettings()
        rows = oSettings.aoData
        index = Template.dataTable.getRowIndexById _id, rows
        unless index
          dataTable.fnAddData fields
        ###
      #====== callback fired whenever a new document is changed that matches the cursor ======#
      changed: ( _id, fields ) ->
        oSettings = dataTable.fnSettings()
        rows = oSettings.aoData
        index = Template.dataTable.getRowIndexById _id, rows
        if index
          row = collection.findOne _id
          dataTable.fnUpdate row, index
      #====== callback fired whenever a new document is added that matches the cursor ======#
      moved: ( document, oldIndex, newIndex ) ->
        console.log( "row moved: ", document )
      #====== callback fired whenever a new document is removed that matches the cursor ======#
      removed: ( _id ) ->
        oSettings = dataTable.fnSettings()
        rows = oSettings.aoData
        index = Template.dataTable.getRowIndexById _id, rows
        if index
          dataTable.fnDeleteRow index
#====== /Observers ======#

#====== Filters ======#
Template.dataTable.prepareFilters = ->
  self = @
  tI = self.templateInstance
  selector = self.getSelector()
  #===== Adding placeholder to Datatable filter input field =====#
  $(".#{selector} .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."
  #===== Datatable with footer filters ======#
  if selector is 'datatable-add-row'
    $(".#{selector} .dataTables_wrapper tfoot input").keyup ->
      target = @
      tI.dataTable.fnFilter target.value, $(".#{selector} .dataTables_wrapper tfoot input").index( target )
#====== /Filters ======#

#====== Pagination ======#
Template.dataTable.preparePagination = ->
  selector = @getSelector()
  #===== Datatable results selector init ======#
  if $().select2 isnt undefined
    $(".#{ selector } .dataTables_length select").select2 minimumResultsForSearch: "-1"
#====== /Pagination ======#

#====== Presets ======#
# TODO : this is temporary all of this should be passed in through the options param
Template.dataTable.presetOptions = ->
  self = @
  selector = self.templateInstance.data.selector
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

#====== Utility ======#
Template.dataTable.getRowIndexById = ( _id, rows ) ->
  index = 0
  rowFound = rows.some ( row ) ->
    if row._aData._id is _id
      return true
    index++
  if rowFound
    return index
  else return false

Template.dataTable.setDefaultCellValue = ( column ) ->
  Match.test column.mData, String
  Match.test column.sTitle, String
  unless column.mRender
    column.mRender = ( dataSource, call, rawData ) -> rawData[ column.mData ] ?= ""
#====== /Utility ======#