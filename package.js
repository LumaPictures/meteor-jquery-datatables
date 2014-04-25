Package.describe({
  summary: "Sort, page, and filter millions of records. Reactively."
});

Package.on_use(function (api, where) {
  api.use([
    'coffeescript'
  ],['client', 'server']);

  // for helpers
  api.use([
    'jquery',
    'ui',
    'templating',
    'spacebars'
  ], 'client');

  api.add_files([
    'vendor/datatables.min.js',
    'vendor/tabletools.min.js',
    'vendor/columnFilterWidgets.js',
    'lib/datatables.html',
    'lib/datatables.client.coffee'
  ], ['client']);

  api.add_files([
    'lib/datatables.server.coffee'
  ],['server']);

  api.export([
    'DataTable'
  ],['client','server']);

  api.export([
    'DataTableSubscriptionCount'
  ],[ 'client' ]);
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
