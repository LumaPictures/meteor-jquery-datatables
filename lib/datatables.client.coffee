# Client
# ======
DataTable.countCollection = new Meteor.Collection "datatable_subscription_count"

DataTable.defaultOptions =
  bJQueryUI: false
  bAutoWidth: true
  bDeferRender: false
  bScrollCollapse: false
  sPaginationType: "full_numbers"
  # ##### Bootstrap 3 Markup
  # You can change this by setting `Template.dataTable.defaultOptions.sDom` property.
  # For some example Less / CSS styles check out [luma-ui's dataTable styles](https://github.com/LumaPictures/luma-ui/blob/master/components/dataTables/dataTables.import.less)
  sDom: "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  oLanguage:
    sSearch: "_INPUT_"
    sLengthMenu: "<span>Show :</span> _MENU_"
    # ##### Loading Message
    # Set `oLanguage.sProcessing` to whatever you want, event html. I haven't tried a Meteor template yet, could be fun!
    sProcessing: "Loading"
    oPaginate:
      sFirst: "First"
      sLast: "Last"
      sNext: ">"
      sPrevious: "<"

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