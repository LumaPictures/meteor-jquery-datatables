# Client
# ======
DataTable.countCollection = new Meteor.Collection "datatable_subscription_count"

Template.dataTable = _.extend Template.dataTable, DataTable

$.fn.dataTableExt.oApi.fnGetComponent = ->
  oSettings = @fnSettings()
  if oSettings
    if oSettings.oInit
      return oSettings.oInit.component or false
  throw new Error "DataTable Blaze component not instantiated"

# ## Initialization

# ##### rendered()
# When the component is first rendered datatables is initialized `templateInstance.__component__` is the this context
Template.dataTable.rendered = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.log "rendered", @
  instantiatedComponent.initialize()

# ##### created()
Template.dataTable.created = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.log "created", @
  instantiatedComponent.prepareQuery()
  instantiatedComponent.prepareCollection()
  instantiatedComponent.prepareColumns()
  instantiatedComponent.prepareRows()
  instantiatedComponent.prepareOptions()

# ##### destroyed()
# Currently nothing is done when the component is destroyed.
Template.dataTable.destroyed = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.log "destroyed", @

# ##### initialize()
# Set the initial table properties from the component declaration, initialize the jQuery DataTables object, and initialize
# other third parties if they exist ( plugins, select2, etc. )
Template.dataTable.initialize = ->
  @initializeDataTable()
  @initializeFilters()
  @initializeDisplayLength()
  @log "initialized", @
