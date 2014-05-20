Tinytest.add "jQuery DataTables Mixins - Query:Definition", ( test ) ->
  test.notEqual DataTableMixins.Query, undefined, "Expected DataTableMixins.Query to be defined on the client and server."

if Meteor.isClient
  Tinytest.add "jQuery DataTables Mixins - Query:prepareQuery()", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.notEqual tI.query, undefined, "When the component is rendered a query method should be defined."
    test.equal tI.query(), ReactiveData.query, "Calling query() on an instantiated component should return the query object."

  Tinytest.add "jQuery DataTables Mixins - Query:prepareTableState()", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    test.notEqual tI.tableState, undefined, "When the component is rendered a query method should be defined."
    test.equal tI.tableState(), undefined, "When the component is rendered the tableState is initially undefined."

  Tinytest.add "jQuery DataTables Mixins - Query:getDataProp( String, Number, Object )", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    data = []
    data[ "key_0" ] =
      value: "value"

    test.equal tI.getDataProp( "key", 0, data ), "value", "Get data prop method should access data in datatables <key>_<value> format"

  Tinytest.add "jQuery DataTables Mixins - Query:mapColumns( Number, Object )", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    column =
      mDataProp: "somePropertyKey"
      bRegex: "someRegex"
      bSearchable: true
      bSortable: true
      sSearch: "someSearchKey"

    data = []
    data[ "mDataProp_0" ] = value: column.mDataProp
    data[ "bRegex_0" ] = value: column.bRegex
    data[ "bSearchable_0" ] = value: column.bSearchable
    data[ "bSortable_0" ] = value: column.bSortable
    data[ "sSearch_0" ] = value: column.sSearch

    tI.tableState columns: []

    tI.mapColumns 0, data

    test.equal tI.tableState().columns[ column.mDataProp ], column, "Calling mapColumn converts datatable column format to key value pairs."

  Tinytest.add "jQuery DataTables Mixins - Query:mapQuery( String, Object, Object )", ( test ) ->
    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    searchQuery = $or: []

    tI.tableState
      sSearch: "someSearch"

    column =
      mDataProp: "somePropertyKey"
      bRegex: "someRegex"
      bSearchable: true
      bSortable: true
      sSearch: "someSearchKey"

    tI.mapQuery column.mDataProp, column, searchQuery

    orProperty =
      $regex: tI.tableState().sSearch
      $options: "i"

    key = searchQuery.$or[ 0 ].somePropertyKey
    regex = key.$regex
    options = key.$options

    test.equal regex, orProperty.$regex, "Calling mapQuery should set an and property on each searchable key with the global search."
    test.equal options, orProperty.$options, "Calling mapQuery should set an and property on each searchable key with the global search."

  Tinytest.add "jQuery DataTables Mixins - Query:mapSortOrder( Number, Object )", ( test ) ->
    column =
      mDataProp: "somePropertyKey"

    otherColumn =
      mDataProp: "someOtherKey"

    data = []
    data[ "mDataProp_0" ] = value: column.mDataProp
    data[ "iSortCol_0" ] = value: 0
    data[ "sSortDir_0" ] = value: "asc"
    data[ "mDataProp_1" ] = value: otherColumn.mDataProp
    data[ "iSortCol_1" ] = value: 1
    data[ "sSortDir_1" ] = value: "desc"

    sortIndex = 1

    component = UI.renderWithData Template.DataTable, ReactiveData
    tI = component.templateInstance
    $DOM = $( '<div id="parentNode"></div>' )
    UI.insert component, $DOM

    tI.tableState
      sort: {}

    tI.mapSortOrder 1, data
    tI.mapSortOrder 2, data

    console.log tI.tableState()

    test.equal tI.tableState().sort[ column.mDataProp ], 1, "A datatable with sort asc set maps to a sort element in the tablestate of 1."
    test.equal tI.tableState().sort[ otherColumn.mDataProp ], -1, "A datatable with sort desc set maps to a sort element in the tablestate of -1."











