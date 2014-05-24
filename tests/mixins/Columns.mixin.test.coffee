Tinytest.add "jQuery DataTables Mixins - Columns:Definition", ( test ) ->
  test.notEqual DataTableMixins.Columns, undefined, "Expected DataTableMixins.Columns to be defined on the client and server."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Columns:Rendered", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    staticComponent = UI.renderWithData Template.DataTable, StaticData
    tI2 = staticComponent.templateInstance
    UI.insert staticComponent, $DOM

    test.notEqual tI.columns, undefined, "Component should have a columns method defined."
    test.equal tI.columns().length, ( ReactiveData.columns.length ), "Components columns arrary should be the same as initializer columns array with an extra id column."
    test.equal tI.columns()[0].mRender( {}, "", [ "platform": null ] ), "", "All columns have a default mRender function that returns an empty string."
