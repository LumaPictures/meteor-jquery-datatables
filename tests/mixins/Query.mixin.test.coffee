Tinytest.add "jQuery DataTables Mixins - Query:Definition", ( test ) ->
  test.notEqual DataTableMixins.Query, undefined, "Expected DataTableMixins.Query to be defined on the client and server."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Query:prepareQuery()", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.notEqual tI.query, undefined, "When the component is rendered a query method should be defined."
    test.notEqual tI.tableState, undefined, "When the component is rendered a query method should be defined."
    test.equal tI.query(), ReactiveData.query, "Calling query() on an instantiated component should return the query object."




