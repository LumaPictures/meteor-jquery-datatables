# Client
# ======
DataTable.countCollection = new Meteor.Collection "datatable_subscription_count"

Template.dataTable = _.extend Template.dataTable, DataTable

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
  instantiatedComponent.prepareSelector()
  instantiatedComponent.prepareCollection()
  instantiatedComponent.prepareQuery()
  instantiatedComponent.prepareColumns()
  instantiatedComponent.prepareRows()
  instantiatedComponent.prepareOptions()
  instantiatedComponent.log "created", @

# ##### destroyed()
# Currently nothing is done when the component is destroyed.
Template.dataTable.destroyed = ->
  templateInstance = @
  instantiatedComponent = templateInstance.__component__
  instantiatedComponent.destroy()
  instantiatedComponent.log "destroyed", @