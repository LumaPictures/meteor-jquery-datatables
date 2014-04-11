# Set default table template
Template.dataTable.default_template = 'default_table_template'

# Return the template specified in the component parameters
Template.dataTable.chooseTemplate = ( table_template = null ) ->
  table_template ?= Template.dataTable.default_template
  if Template[ table_template ]
    return Template[ table_template ]
  else return Template[ Template.dataTable.default_template ]

#====== Options
# Global defaults for all datatables
# These can be overridden in the options parameter
Template.dataTable.defaultOptions =
  #===== Default Table
  # * Pagination
  # * Filtering
  # * Sorting
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

Template.dataTable.setOptions = ( options ) ->
  Match options, Object
  @templateInstance.data.options = options

Template.dataTable.getOptions = -> return @templateInstance.data.options or @presetOptions() or false

# Prepares the options object by merging the options passed in with the defaults
Template.dataTable.prepareOptions = ->
  self = @
  options = self.getOptions() or {}
  columns = self.prepareColumns self.getColumns()
  rows = self.prepareRows self.getRows()
  if rows
    options.aaData = rows
  if columns
    options.aoColumns = columns
  self.setOptions _.defaults( options, self.defaultOptions )

#====== Selector
Template.dataTable.setSelector = ( selector ) ->
  Match selector, String
  @templateInstance.data.selector = selector

Template.dataTable.getSelector = -> return @templateInstance.data.selector or false

Template.dataTable.prepareSelector = -> return

#====== Query
Template.dataTable.setQuery = ( query ) ->
  Match query, Object
  @templateInstance.data.query = query

Template.dataTable.prepareQuery = -> return

Template.dataTable.getQuery = -> return @templateInstance.data.query or false

#====== Collection
Template.dataTable.setCollection = ( collection ) ->
  Match collection, Object
  @templateInstance.data.collection = collection

Template.dataTable.prepareCollection = -> return

Template.dataTable.getCollection = -> return @templateInstance.data.collection or false

#====== Rows
Template.dataTable.setRows = ( rows ) ->
  Match rows, Array
  @templateInstance.data.rows = rows

Template.dataTable.prepareRows = -> return

Template.dataTable.getRows = -> return @templateInstance.data.rows or false

#====== Columns
Template.dataTable.setColumns = ( columns ) ->
  Match columns, Array
  @templateInstance.data.columns = columns

Template.dataTable.prepareColumns = -> return

Template.dataTable.getColumns = -> return @templateInstance.data.columns or false

#====== Cursor
Template.dataTable.setCursor = ( cursor ) ->
  Match cursor, Object
  @templateInstance.data.cursor = cursor

Template.dataTable.prepareCursor = ->
  query = @getQuery()
  collection = @getCollection()
  if query and collection
    @setCursor collection.find query

Template.dataTable.getCursor = -> return @templateInstance.data.cursor or false

#====== DataTable
Template.dataTable.getDataTable = -> return @templateInstance.dataTable or false

Template.dataTable.setDatatTable = ( dataTable ) ->
  Match dataTable, Object
  @templateInstance.dataTable = dataTable

Template.dataTable.prepareObservers = ->
  self = @
  tI = self.templateInstance
  collection = self.getCollection()
  cursor = self.getCursor
  #===== Setup observers to add and remove rows from the dataTable
  if cursor
    cursor.observeChanges
      added: ( _id, fields ) ->
        fields._id = _id
        tI.dataTable.fnAddData fields

      changed: ( _id, fields ) ->
        oSettings = tI.dataTable.fnSettings()
        aoData = oSettings.aoData
        counter = 0
        index = 0
        aoData.some ( row ) =>
          if row._aData._id is _id
            index = counter
            return true
          counter++
        tI.dataTable.fnUpdate collection.findOne( _id ), index

      moved: (document, oldIndex, newIndex) ->
        console.log("row moved: ", document)

      removed: ( _id ) ->
        oSettings = tI.dataTable.fnSettings()
        aoData = oSettings.aoData
        counter = 0
        index = 0
        aoData.some ( row ) =>
          if row._aData._id is _id
            index = counter
            return true
          counter++
        tI.dataTable.fnDeleteRow index

Template.dataTable.prepareFilters = ->
  self = @
  tI = self.templateInstance
  selector = self.getSelector()
  #===== Adding placeholder to Datatable filter input field =====//
  $(".#{selector} .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."

  #===== Datatable with footer filters
  if selector is 'datatable-add-row'
    $(".#{selector} .dataTables_wrapper tfoot input").keyup ->
      target = @
      tI.dataTable.fnFilter target.value, $(".#{selector} .dataTables_wrapper tfoot input").index( target )

Template.dataTable.preparePagination = ->
  selector = @getSelector()
  #===== Datatable results selector init
  if $().select2 isnt undefined
    $(".#{ selector } .dataTables_length select").select2 minimumResultsForSearch: "-1"

Template.dataTable.prepareDataTable = ->
  self = @
  options = self.getOptions()
  selector = self.getSelector()
  self.setDatatTable $(".#{ selector } table").dataTable( options )
  self.prepareObservers()
  self.prepareFilters()
  self.preparePagination()

Template.dataTable.initialize = ->
  @prepareQuery()
  @prepareCollection()
  @prepareCursor()
  @prepareOptions()
  @prepareDataTable()


Template.dataTable.rendered = ->
  templateInstance = @
  component = templateInstance.__component__
  # Merge options with defaults
  component.initialize()

# TODO : this is temporary all of this should be passed in through the options param
Template.dataTable.presetOptions = ->
  self = @
  selector = self.templateInstance.data.selector

  #===== Table with tasks =====
  if selector is 'datatable-tasks'
    options =
      aoColumnDefs: [{
        bSortable: false
        aTargets: [5]
      }]

  #===== Table with invoices =====
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

  #===== Table with selectable rows =====
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

  #===== Table with media objects
  if selector is 'datatable-media'
    options =
      aoColumnDefs: [
        bSortable: false
        aTargets: [
          0
          4
        ]
      ]

  #===== Table with two button pager
  if selector is 'datatable-pager'
    options =
      sPaginationType: "two_button"
      oLanguage:
        sSearch: "<span>Filter:</span> _INPUT_"
        sLengthMenu: "<span>Show entries:</span> _MENU_"
        oPaginate:
          sNext: "Next →"
          sPrevious: "← Previous"

  #===== Table with tools
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

  #===== Table with custom sorting columns
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