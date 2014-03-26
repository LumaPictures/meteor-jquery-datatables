# Return the template specified in the component parameters
Template.dataTable.chooseTemplate = (table_template) -> Template[ table_template or 'default_table_template' ]

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

# Prepares the options object by merging the options passed in with the defaults
Template.dataTable.prepareOptions = ->
  options = @templateInstance.data.options or @presetOptions() or {}
  context = @templateInstance.data.context or []
  selector = @templateInstance.data.selector
  if context.rows and context.columns
    options.aaData = context.rows
    options.aoColumns = context.columns
  @templateInstance.data.options = _.defaults options, @defaultOptions

# Creates an instance of dataTable with the given options and attaches it to this template instance
Template.dataTable.initialize = ->
  tI = @templateInstance
  selector = tI.data.selector
  options = tI.data.options
  #===== Initialize DataTable object and attach to templateInstance
  tI.dataTable = $(".#{selector} table").dataTable options
  #===== Datatable with footer filters
  if selector is 'datatable-add-row'
    $(".#{selector} .dataTables_wrapper tfoot input").keyup ->
      self = @
      tI.dataTable.fnFilter self.value, $(".#{selector} .dataTables_wrapper tfoot input").index(self)
  #===== Datatable results selector init
  $(".#{selector} .dataTables_length select").select2 minimumResultsForSearch: "-1"
  #===== Adding placeholder to Datatable filter input field =====//
  $(".#{selector} .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."


Template.dataTable.rendered = ->
  component = @__component__
  # Merge options with defaults
  component.prepareOptions()
  # Initialze DataTable
  component.initialize()
  # TODO : add a global debug flag for console
  # console.log "rendered::" + @data.selector
  # console.log @

# TODO : this is temporary all of this should be passed in through the options param
Template.dataTable.presetOptions = ->
  selector = @templateInstance.data.selector

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