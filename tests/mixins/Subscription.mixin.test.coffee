Tinytest.add "jQuery DataTables Mixins - Subscription:Definition", ( test ) ->
  test.notEqual DataTableMixins.Subscription, undefined, "Expected DataTableMixins.Subscription to be defined on the client and server."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Subscription:Rendered", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.notEqual tI.setSubscriptionOptions, undefined, "On render setSubscriptionOptions() should be defined"
    test.equal tI.subscriptionOptions, undefined, "On render setSubscriptionOptions() should not be defined"
    test.notEqual tI.setSubscriptionHandle, undefined, "On render setSubscriptionHandle() should be defined"
    test.equal tI.subscriptionHandle, undefined, "On render subscriptionHandle() should not be defined"
    test.notEqual tI.setSubscriptionAutorun, undefined, "On render setSubscriptionAutorun() should be defined"
    test.equal tI.subscriptionAutorun, undefined, "On render subscriptionAutorun() should not be defined"

  Tinytest.add "jQuery DataTables Mixins - Subscription:setSubscriptionOptions()", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    options =
      skip: 0
      limit: 10
      sort: []

    tI.tableState
      iDisplayStart: options.skip
      iDisplayLength: options.limit
      sort: options.sort

    tI.setSubscriptionOptions()

    test.notEqual tI.subscriptionOptions, undefined, "After running set subscriptionOptions subscriptionOptions should be defined."
    test.equal tI.subscriptionOptions(), options, "setSubscriptionOptions should parse the datatable options into a mongoDB options object."


