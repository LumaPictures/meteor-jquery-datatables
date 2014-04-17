# Luma DataTables Default Options

All options passed through the options parameter will be merged with the default options.

e.g. `_.defaults options, defaultOptions`

## Default Markup

By default this datatable component renders datatables using Twitter Bootstrap 3 markup.

You can change this by setting `Template.dataTable.defaultOptions.sDom` property.

## Defaults Object

```coffeescript
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
``