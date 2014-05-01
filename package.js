Package.describe({
  summary: "Sort, page, and filter millions of records. Reactively."
});

Package.on_use(function (api, where) {
  api.use([
    'coffeescript',
    'underscore'
  ],[ 'client', 'server' ]);

  // for helpers
  api.use([
    'jquery',
    'ui',
    'templating',
    'spacebars'
  ], [ 'client' ]);

  api.export([
    'DataTableMixins',
    'DataTable'
  ], ['client','server']);

  /* External Libraries */
  api.add_files([
    'vendor/DataTables-1.10.0/media/js/jquery.dataTables.min.js'
  ], ['client']);

  /* Mixins */
  api.add_files([
    'lib/mixins/dataTableMixins.coffee',
    'lib/mixins/debug.coffee'
  ], [ 'client', 'server' ]);

  api.add_files([
    'lib/mixins/publish.coffee'
  ], [ 'server' ]);

  api.add_files([
    'lib/mixins/initialize.coffee',
    'lib/mixins/collection.coffee',
    'lib/mixins/columns.coffee',
    'lib/mixins/cursor.coffee',
    'lib/mixins/filters.coffee',
    'lib/mixins/options.coffee',
    'lib/mixins/presetTables.coffee',
    'lib/mixins/query.coffee',
    'lib/mixins/queryBuilder.coffee',
    'lib/mixins/rows.coffee',
    'lib/mixins/selector.coffee',
    'lib/mixins/subscription.coffee',
    'lib/mixins/tableTemplate.coffee',
    'lib/mixins/utility.coffee'
  ], [ 'client' ]);

  api.add_files([
    'lib/datatables.component.coffee'
  ], [ 'client', 'server']);

  api.add_files([
    'lib/datatables.html',
    'lib/datatables.client.coffee'
  ], [ 'client' ]);

  /* Plugins */
  // column filter plugin
  api.add_files([
    'lib/plugins/columnFilter/columnFilter.html',
    'lib/plugins/columnFilter/columnFilter.plugin.coffee'
  ], [ 'client' ]);
});

Package.on_test(function (api) {
  api.use([
    'coffeescript',
    'jquery-datatables',
    'tinytest',
    'test-helpers'
  ], ['client', 'server']);

  api.add_files([
    'tests/datatables.test.coffee'
  ], ['client', 'server']);
});
