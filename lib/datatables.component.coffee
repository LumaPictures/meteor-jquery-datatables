if Meteor.isClient
  DataTable = _.extend DataTableMixins.Init,
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

else if Meteor.isServer
  DataTable = _.extend DataTableMixins.Publish, DataTableMixins.Debug