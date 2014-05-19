# # Nested DataTable

# ###### nestedTable.created()
Template.nestedTable.created = -> return

# ###### nestedTable.rendered()
Template.nestedTable.rendered = -> return

# ###### nestedTable.destroyed()
Template.nestedTable.destroyed = -> return

# ###### nestedTable.events()
Template.nestedTable.events
  "click td.details-control": ( event, template ) ->
    tr = event.currentTarget.parentElement
    row = @self.$.api().row( tr )
    if row.child.isShown()
      # This row is already open - close it
      row.child.hide()
      $( tr ).find( ".details-control i" ).removeClass( "icon-minus" ).addClass( "icon-plus" )
    else
      # Open this row
      component = UI.renderWithData( Template.childTable, row.data()).render().toHTML()
      row.child( component ).show()
      $( tr ).find( ".details-control i" ).removeClass( "icon-plus" ).addClass( "icon-minus" )

Template.nestedTable.pages = -> return {
  # ## Columns
  #   * `data` maps the object properties to column headings
  #   * `title` is the column heading
  #   * `mRender` is a custom render function for that property ( default is "" )
  columns: [{
    class: "details-control"
    orderable: false
    data: null
    mRender: -> UI.renderWithData( Template.icon, { styles: "icon-plus" } ).render().toHTML()
  },{
    title: "Route"
    data: "route"
  },{
    title: "Path"
    data: "path"
  },{
    title: "Controller"
    data: "controller"
    mRender:  ( data, type, row ) ->
      row.controller ?= "null"
  },{
    title: "Title"
    data: "page.title"
    mRender:  ( data, type, row ) ->
      row.page.title ?= ""
  },{
    title: "Subtitile"
    data: "page.subtitle"
    mRender:  ( data, type, row ) ->
      row.page.subtitle ?= ""
  },{
    title: "External Route"
    data: "external"
    mRender: ( data, type, row ) ->
      row.external ?= "false"
  }]
  # ## Rows
  #   * Array data source for this table
  rows: Router.collection.find().fetch()
}