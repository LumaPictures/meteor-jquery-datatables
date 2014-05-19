Tinytest.add "jQuery DataTables Mixins - Columns:Definition", ( test ) ->
  test.notEqual DataTableMixins.Columns, undefined, "Expected DataTableMixins.Columns to be defined on the client and server."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Columns:Rendered", ( test ) ->
    component = UI.renderWithData Template.dataTable, RowsData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    staticComponent = UI.renderWithData Template.dataTable, PageData
    tI2 = staticComponent.templateInstance
    UI.insert staticComponent, $DOM

    idColumn =
      title: "id"
      data: "_id"
      visible: false
      searchable: false

    lastColumn = _.omit tI.columns()[ tI.columns().length - 1 ], "mRender"
    lastColumnStatic = _.omit tI2.columns()[ tI2.columns().length - 1 ], "mRender"

    test.notEqual tI.columns, undefined, "Component should have a columns method defined."
    test.equal lastColumn, idColumn, "Reactive Components last column should be a hidden id column."
    test.notEqual lastColumnStatic, idColumn, "Static Components should not have a hidden id column."
    test.equal tI.columns().length, ( RowsData.columns.length ), "Components columns arrary should be the same as initializer columns array with an extra id column."
    test.equal tI.columns()[0].mRender( {}, "", [ "platform": null ] ), "", "All columns have a default mRender function that returns an empty string."
