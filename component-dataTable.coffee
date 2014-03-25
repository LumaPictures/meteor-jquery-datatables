Template.dataTable.chooseTemplate = (table_template) -> Template[ table_template or 'default_table_template' ]

Template.dataTable.rendered = ->
  templateInstance = @
  selector = templateInstance.data.selector
  options = templateInstance.data.options or presetOptions(selector) or {}
  context = templateInstance.data.context or []

  console.log 'rendered : ' + selector
  console.log templateInstance

  #===== Default Table
  # * Pagination
  # * Filtering
  # * Sorting
  defaultOptions =
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

  if context.rows and context.headers
    defaultOptions.aaData = context.rows
    defaultOptions.aoColumns = context.columns

  #===== Datatable init
  templateInstance.dataTable = $(".#{selector} table").dataTable _.defaults options, defaultOptions

  #===== Datatable with footer filters
  if selector is 'datatable-add-row'
    $(".#{selector} .dataTables_wrapper tfoot input").keyup ->
      self = @
      templateInstance.dataTable.fnFilter self.value, $(".#{selector} .dataTables_wrapper tfoot input").index(self)

  #===== Datatable results selector init
  $(".#{selector} .dataTables_length select").select2 minimumResultsForSearch: "-1"

  #===== Adding placeholder to Datatable filter input field =====//
  $(".#{selector} .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."

# TODO : this is temporary all of this should be passed in through the options param
presetOptions = (selector) ->
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