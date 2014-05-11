if Meteor.isClient
  DataTable = _.extend DataTableMixins.Initialize,
    DataTableMixins.Destroy,
    DataTableMixins.Collection,
    DataTableMixins.Columns,
    DataTableMixins.Cursor,
    DataTableMixins.Filters,
    DataTableMixins.Options,
    DataTableMixins.PresetTables,
    DataTableMixins.Query,
    DataTableMixins.QueryBuilder,
    DataTableMixins.Rows,
    DataTableMixins.Selector,
    DataTableMixins.Subscription,
    DataTableMixins.TableTemplate,
    DataTableMixins.Utility,
    DataTableMixins.Debug

  DataTable.defaultOptions =
    # ###### Display Options
    jQueryUI: false
    autoWidth: true
    deferRender: false
    scrollCollapse: false
    paginationType: "full_numbers"
    # ##### Bootstrap 3 Markup
    # You can change this by setting `Template.dataTable.defaultOptions.sDom` property.
    # For some example Less / CSS styles check out [luma-ui's dataTable styles](https://github.com/LumaPictures/luma-ui/blob/master/components/dataTables/dataTables.import.less)
    dom: "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
    # ###### Language Options
    language:
      search: "_INPUT_"
      lengthMenu: "<span>Show :</span> _MENU_"
    # ##### Loading Message
    # Set `oLanguage.sProcessing` to whatever you want, event html. I haven't tried a Meteor template yet, could be fun!
      processing: "Loading"
      paginate:
        first: "First"
        last: "Last"
        next: ">"
        previous: "<"

  $.fn.dataTableExt.oApi.fnGetComponent = ->
    oSettings = @fnSettings()
    if oSettings
      if oSettings.oInit
        return oSettings.oInit.component or false
    throw new Error "DataTable Blaze component not instantiated"

else if Meteor.isServer
  DataTable = _.extend DataTableMixins.Publish, DataTableMixins.Debug