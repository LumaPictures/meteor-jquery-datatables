Package.describe({
  summary: "A reactive dataTable component"
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
    'spacebars',
    'less'
  ], 'client', {weak: true});

  api.use('module-layout', 'client', {unordered: true});

  api.add_files([
    'lib/datatables.min.js',
    'lib/tabletools.min.js',
    'component-dataTable.html',
    'component-dataTable.coffee'
  ], ['client']);
});

Package.on_test(function (api) {
  api.use('component-dataTable');
});
