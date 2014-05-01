# ##### Column Filters
ColumnDrillDownFilters =
  initializeColumnDrilldownFilters: ->
    @prepareColumnDrilldownFilterContainer()
    return @getColumnDrilldownFilterContainer()

  prepareColumnDrilldownFilterContainer: ->
    container = UI.renderWithData Template.dataTableColumnDrilldownFilterContainer, @getData()
    @setColumnDrilldownFilterContainer container

  setColumnDrilldownFilterContainer: ( markup ) ->
    Match.test markup, String
    @getTemplateInstance().$ColumnDrilldownFilterContainer = $( markup )

  getColumnDrilldownFilterContainer: ->
    if @getTemplateInstance().$ColumnDrilldownFilterContainer
      return @getTemplateInstance().$ColumnDrilldownFilterContainer[ 0 ].dom.members[ 1 ] or false

Template.dataTable = _.extend Template.dataTable, ColumnDrillDownFilters

Template.dataTable.events
  'click .drilldown.column-filter-widget': ( event, template ) ->
    console.log template
    console.log event

# * Register the Columng Filter Widget feature with DataTables
$.fn.dataTableExt.aoFeatures.push
  fnInit: ( oSettings ) ->
    component = oSettings.oInstance.fnGetComponent()
    return component.initializeColumnDrilldownFilters()
  cFeature: "W"
  sFeature: "ColumnDrilldownFilters"

Template.dataTableColumnDrilldownFilterContainer.created = ->
  console.log @

Template.dataTableColumnDrilldownFilterContainer.filterableColumns = ->
  return [
    {
      name: 'test'
    },{
      name: 'test2'
    }
  ]
