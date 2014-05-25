class DataTableComponent extends Component
  __name__: "DataTable"
  @extend DataTableMixins.Base
  @extend DataTableMixins.Collection
  @extend DataTableMixins.Query
  @extend DataTableMixins.Subscription

  if Meteor.isClient
    @extend DataTableMixins.Columns
    @extend DataTableMixins.Rows
    @extend ComponentMixins.ChooseTemplate

  if Meteor.isServer
    @extend DataTableMixins.Publish

  constructor: ( context = {} ) ->
    super
    @prepareSubscription()
    @prepareCollection()
    @prepareCountCollection()
    @prepareQuery()
    if Meteor.isClient
      @prepareColumns()
      @prepareRows()
      @prepareOptions()
      @prepareTableState()

  # ##### rendered()
  rendered: ->
    if Meteor.isClient
      @$ = $("#{ @selector() } table").dataTable @options()
      @log "$", @$
      @initializeFilterPlaceholder()
      # TODO : footer filters
      # @initializeFooterFilter()
      @initializeDisplayLength()
    super

  # ##### destroyed()
  destroyed: ->
    if Meteor.isClient
      if $(".ColVis_collection") then $(".ColVis_collection").remove()
      if @subscriptionAutorun and @subscriptionAutorun().stop then @subscriptionAutorun().stop()
    super

  # ##### fnServerData()
  # The callback for every dataTables user / reactivity event
  # ###### Parameters
  #   + `sSource` is the currently useless `sAjaxProp` from the options
  #   + `aoData` is an array of objects provided by datatables reflecting its current state
  #   + `fnCallback` is the function that will be called when the server returns a result
  #   + `oSettings` is the datatables settings object
  fnServerData: ( sSource, aoData, fnCallback, oSettings ) ->
    if Meteor.isClient
      # `setTableState()` parses aoData and creates a usable table state object.
      @mapTableState aoData
      # `setSubscriptionOptions()` turns the table state into a MongoDB query options object.
      @setSubscriptionOptions()
      # `setSubscriptionHandle()` subscribes the the dataset for the current table state.
      @setSubscriptionHandle()
      # `setSubscriptionAutorun()` creates a Deps.autrun computation. The autorun computation will call datatables fnCallback
      # when the current table state subscription is ready.
      @setSubscriptionAutorun fnCallback
    else throw new Error "fnServerData can only be called from the client."

if Meteor.isClient
  # DataTable Client
  # ================
  # ##### Extending the Template
  # `Template.dataTable` is extended with `DataTableComponent`'s methods so that the template callbacks can execute
  # `DataTableComponent` instance methods. In truth `Template.dataTable` is the actual `DataTableComponent`.

  # ##### created()
  # This is the component constructor.
  Template.DataTable.created = -> new DataTableComponent @

  # ##### DataTable Plugin fnGetComponent()
  $.fn.dataTableExt.oApi.fnGetComponent = ->
    oSettings = @fnSettings()
    if oSettings
      if oSettings.oInit
        return oSettings.oInit.component or false
    throw new Error "DataTable Blaze component not instantiated"
