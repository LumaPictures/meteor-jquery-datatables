Tinytest.add "jQuery DataTables Mixins - Base:Definition", ( test ) ->
  test.notEqual DataTableMixins.Base, undefined, "Expected DataTableMixins.Base to be defined on the client and server."

Tinytest.add "jQuery DataTables Mixins - Base:Defaults", ( test ) ->
  if Meteor.isClient
    component = UI.renderWithData Template.dataTable, _.omit( RowsData, "options" )
    component = component.templateInstance
  if Meteor.isServer
    component = new DataTableComponent _.omit( RowsData, "options" )

    test.notEqual component.defaults, undefined, "Component defaults should be set on the client."
    test.equal _.isObject( component.defaults() ), true, "Calling the defaults method should returnt he defaults object."
    defaultOptions = _.pick component.options(), _.keys( component.defaults() )
    test.equal defaultOptions, component.defaults(), "Component with no options should have options set to defaults."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Base:Rendered:Reactive", ( test ) ->
    component = UI.renderWithData Template.dataTable, RowsData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.equal tI.options().data, [], "Component with reactive datasource should have an empty options.data array."
    test.equal _.isArray( tI.columns() ), true, "Component with reactive datasource should have a columns array."
    test.notEqual tI.options().serverSide, undefined, "Component with reactive datasource should have severSide option defined."
    test.notEqual tI.options().processing, undefined, "Component with reactive datasource should have processing option defined."
    test.notEqual tI.options().ajaxSource, undefined, "Component with reactive datasource should have ajaxSource option defined."
    test.notEqual tI.options().serverData, undefined, "Component with reactive datasource should have serverData option defined."

  Tinytest.add "jQuery DataTables Mixins - Base:Rendered:Static", ( test ) ->
    component = UI.renderWithData Template.dataTable, PageData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.equal tI.options().data, PageData.rows, "Component with static datasource should have an empty options.data array."
    test.equal _.isArray( tI.columns() ), true, "Component with static datasource should have a columns array."
    test.equal tI.options().serverSide, undefined, "Component with static datasource should not have severSide option defined."
    test.equal tI.options().processing, undefined, "Component with static datasource should not have processing option defined."
    test.equal tI.options().ajaxSource, undefined, "Component with static datasource should not have ajaxSource option defined."
    test.equal tI.options().serverData, undefined, "Component with static datasource should not have serverData option defined."


