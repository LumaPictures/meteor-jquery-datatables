Tinytest.add "jQuery DataTables Mixins - Rows:Definition", ( test ) ->
  test.notEqual DataTableMixins.Rows, undefined, "Expected DataTableMixins.Rows to be defined on the client and server."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Rows:Rendered", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.notEqual tI.rows, undefined, "Component should have a rows method defined."
    test.equal _.isArray( tI.rows() ), true, "Calling the rows method should return an array of rows or an empty array."