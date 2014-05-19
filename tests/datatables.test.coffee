@unsetCollection = ( name ) ->
  collection = getCollection name
  console.log collection

Tinytest.add "jQuery DataTables - Definition", ( test ) ->
  test.notEqual DataTableComponent, undefined, "Expected DataTableComponent to be defined on the client and server."
  test.notEqual DataTableMixins, undefined, "Expected DataTableComponent to be defined on the client and server."

  if Meteor.isClient
    test.notEqual $().dataTable, undefined, "Expected DataTable jQuery plugin to be defined on the client."
    test.notEqual Template.dataTable, undefined, "Expected Template.dataTable to be defined on the client."

Tinytest.add "jQuery DataTables - Constructor", ( test ) ->
  if Meteor.isClient
    component = UI.renderWithData Template.dataTable, RowsData
    tI = component.templateInstance

    test.equal tI.__name__, "DataTableComponent", "Class __name__ should be DataTableComponent"
    test.notEqual tI.id, undefined, "Component should have id method defined."
    test.equal tI.id(), RowsData.id, "Component id should be equal the id passed in through constructor."

  if Meteor.isServer
    component = new DataTableComponent RowsData
    test.equal component.__name__, "DataTableComponent", "Class __name__ should be DataTableComponent"
    test.notEqual component.id, undefined, "Component should have id method defined."
    test.equal component.id(), RowsData.id, "Component id method should return the id."

if Meteor.isClient
  Tinytest.add "jQuery DataTables - Rendered", ( test ) ->
    component = UI.renderWithData Template.dataTable, RowsData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.notEqual tI.$, undefined, "Component should have a jQuery node defined after being rendered."
    test.notEqual tI.selector, undefined, "Component should have selector method defined."
    test.equal tI.selector(), "##{ RowsData.id }", "Component selector should be based on the id passed in through constructor."
    RowsData.debug = undefined






