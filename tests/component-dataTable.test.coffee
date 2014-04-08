if Meteor.isClient
  Tinytest.add "dataTable Component - defined on client", ( test ) ->
    test.notEqual Template.dataTable, undefined, "Expected Template.dataTable to be defined on the client."