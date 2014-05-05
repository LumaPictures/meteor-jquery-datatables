Template.blazeTemplates.pages = -> return {
  # ## Columns
  #   * `data` maps the object properties to column headings
  #   * `title` is the column heading
  #   * `mRender` is a custom render function for that property ( default is "" )
  columns: [{
    title: "Route"
    data: "route"
  },{
    title: "Path"
    data: "path"
    defaultContent: "null"
    mRender: ( data, type, row ) ->
      component = UI.renderWithData Template.exampleLinkTemplate, {
        href: row.path
        anchor: row.page.title
        title: row.page.subtitle
        target: "_blank"
      }
      return component.render().toHTML()
  },{
    title: "Controller"
    data: "controller"
    mRender:  ( data, type, row ) ->
      component = UI.renderWithData Template.exampleLabelTemplate, {
        label: row.controller or "null"
        class: if row.controller then "label-info" else "label-warning"
      }
      return component.render().toHTML()
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
      component = UI.renderWithData Template.exampleLabelTemplate, {
        label: row.external or "false"
        class: if row.external then "label-success" else "label-danger"
      }
      return component.render().toHTML()
  }]
  # ## Rows
  #   * Array data source for this table
  rows: Router.collection.find().fetch()
}