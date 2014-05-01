if Meteor.isClient
  DataTable = _.extend DataTableMixins.Initialize,
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

  $.fn.dataTableExt.oApi.fnGetComponent = ->
    oSettings = @fnSettings()
    if oSettings
      if oSettings.oInit
        return oSettings.oInit.component or false
    throw new Error "DataTable Blaze component not instantiated"

else if Meteor.isServer
  DataTable = _.extend DataTableMixins.Publish, DataTableMixins.Debug