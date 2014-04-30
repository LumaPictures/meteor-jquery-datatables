if Meteor.isClient
  Template.home.columnFilters = ->
    columnFilters =
      # ## Columns
      #   * `mData` maps the object properties to column headings
      #   * `sTitle` is the column heading
      #   * `mRender` is a custom render function for that property ( default is "" )
      columns: [
        {
          sTitle: "Route"
          mData: "route"
        }
        {
          sTitle: "Path"
          mData: "path"
        }
        {
          sTitle: "Controller"
          mData: "controller"
          mRender:  ( dataSource, call, rawData ) ->
            rawData.controller ?= "null"
        }
        {
          sTitle: "Title"
          mData: "page.title"
          mRender:  ( dataSource, call, rawData ) ->
            rawData.page.title ?= ""
        }
        {
          sTitle: "Subtitile"
          mData: "page.subtitle"
          mRender:  ( dataSource, call, rawData ) ->
            rawData.page.subtitle ?= ""
        }
        {
          sTitle: "External Route"
          mData: "external"
          mRender: ( dataSource, call, rawData ) ->
            rawData.external ?= "false"
        }
      ]
      # ## Selector
      #   * must be unique in page scope
      selector: "dataTable-columnFilters"
      # ## Rows
      #   * Array data source for this table
      rows: Router.collection.find().fetch()
      options:
        sDom: "<\"datatable-header\"Wfl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"

    return columnFilters