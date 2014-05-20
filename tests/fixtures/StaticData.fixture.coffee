@StaticData =
  columns: [{
    title: "Route"
    data: "route"
  },{
    title: "Path"
    data: "path"
  },{
    title: "Controller"
    data: "controller"
  },{
    title: "Title"
    data: "title"
  },{
    title: "Subtitile"
    data: "subtitle"
  },{
    title: "External Route"
    data: "external"
  }]
  # ## Selector
  #   * must be unique in page scope
  selector: "dataTable-pages"
  # ## Rows
  #   * Array data source for this table
  rows: [{
    route: "aRoute"
    path: "/"
    controller: "TestController"
    title: "A Title"
    subtitle: "A Subtitle"
    external: false
  }]