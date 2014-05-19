Package.describe({
  summary: "Sort, page, and filter millions of records. Reactively."
});

Package.on_use(function (api, where) {
  api.use([
    'coffeescript',
    'underscore',
    'luma-component'
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
    'DataTableComponent'
  ], ['client','server']);

  /* External Libraries */
  api.add_files([
    'vendor/DataTables-1.10.0/media/js/jquery.dataTables.min.js',
    'vendor/DataTables-1.10.0/extensions/ColVis/js/dataTables.colVis.min.js',
    'vendor/DataTables-1.10.0/extensions/ColReorder/js/dataTables.colReorder.min.js'
  ], ['client']);

  /* Mixins */
  api.add_files([
    'lib/mixins/Base.mixin.coffee',
    'lib/mixins/Collection.mixin.coffee',
    'lib/mixins/Columns.mixin.coffee',
    'lib/mixins/Publish.mixin.coffee',
    'lib/mixins/Query.mixin.coffee',
    'lib/mixins/Subscription.mixin.coffee',
    'lib/mixins/Rows.mixin.coffee'
  ], [ 'client', 'server' ]);

  /* Component */
  api.add_files([
    'lib/datatables.component.coffee'
  ], [ 'client', 'server']);

  api.add_files([
    'lib/datatables.html',
    'lib/datatables.client.coffee'
  ], [ 'client' ]);

  /* Plugins
  api.add_files([
    'lib/plugins/columnFilter/columnFilter.html',
    'lib/plugins/columnFilter/columnFilter.plugin.coffee'
  ], [ 'client' ]);
  */
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
