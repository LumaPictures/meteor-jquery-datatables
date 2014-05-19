class DataTableComponent extends Component
  @extend DataTableMixins.Base
  @extend DataTableMixins.Collection

  if Meteor.isClient
    @extend DataTableMixins.Columns
    @extend DataTableMixins.Rows
    @extend DataTableMixins.Query
    @extend DataTableMixins.Subscription
    @extend ComponentMixins.ChooseTemplate

  if Meteor.isServer
    @extend DataTableMixins.Publish

  constructor: ( context = {} ) ->
    super
    @prepareCollection()
    @prepareCountCollection()
    if Meteor.isClient
      @prepareQuery()
      @prepareColumns()
      @prepareOptions()
      @prepareTableState()

  # ##### rendered()
  rendered: ->
    @$ = $("#{ @selector() } table").dataTable @options()
    @log "$", @$
    @initializeFilterPlaceholder()
    # TODO : footer filters
    # @initializeFooterFilter()
    @initializeDisplayLength()
    super

  # ##### destroyed()
  destroyed: ->
    if $(".ColVis_collection") then $(".ColVis_collection").remove()
    if @subscriptionAutorun and @subscriptionAutorun().stop then @subscriptionAutorun().stop()
    super

if Meteor.isClient
  $.fn.dataTableExt.oApi.fnGetComponent = ->
    oSettings = @fnSettings()
    if oSettings
      if oSettings.oInit
        return oSettings.oInit.component or false
    throw new Error "DataTable Blaze component not instantiated"
