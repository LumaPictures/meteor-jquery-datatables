if Meteor.isClient
  Tinytest.add "jQuery DataTables - defined on client", ( test ) ->
    test.notEqual $().dataTable, undefined, "Expected DataTable jQuery plugin to be defined on the client."
    test.notEqual Template.dataTable, undefined, "Expected Template.dataTable to be defined on the client."