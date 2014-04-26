if Meteor.isClient
  Template.shittyTable.rendered = ->
    $('#example').dataTable( {
      "sDom": "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"Wip>"
    } )

    $("select").select2
      width: "100%"

  # Array Data Source
  # =================
  # * You can render static ( or client only ) data easily by setting the `rows` property to an array of objects
  ###
  ```html
  {{> dataTable
      selector=pages.selector
      columns=pages.columns
      rows=pages.rows
  }}
  ```
  ###

  Template.home.pages = ->
    pages =
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
      selector: "dataTable-pages"
      # ## Rows
      #   * Array data source for this table
      rows: Router.collection.find().fetch()
    return pages

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
        oColumnFilterWidgets:
          sSeparator: ',  '

    return columnFilters

# Reactive Data Source
# ====================
# * You must setup a Datatables publication on the server.
if Meteor.isServer
  DataTable.debug = "true"
  DataTable.publish "a_browsers", Browsers

  # * Calling `_ensureIndex` is necessary in order to sort and filter collections.
  #   * [see mongod docs for more info](http://docs.mongodb.org/manual/reference/method/db.collection.ensureIndex/)
  Meteor.startup ->
    Browsers._ensureIndex { _id: 1 }, { unique: 1 }
    Browsers._ensureIndex engine: 1
    Browsers._ensureIndex browser: 1
    Browsers._ensureIndex platform: 1
    Browsers._ensureIndex version: 1
    Browsers._ensureIndex grade: 1
    Browsers._ensureIndex createdAt: 1
    Browsers._ensureIndex counter: 1

if Meteor.isClient
  Template.home.browsers = ->
    browsers =
      columns: [
        {
          sTitle: "Engine"
          mData: "engine"
        }
        {
          sTitle: "Browser"
          mData: "browser"
        }
        {
          sTitle: "Platform"
          mData: "platform"
        }
        {
          sTitle: "Version"
          mData: "version"
          sClass: "center"
        }
        {
          sTitle: "Grade"
          mData: "grade"
          sClass: "center"
          mRender: ( dataSource, call, rawData ) ->
            rawData ?= ""
            switch rawData.grade
              when "A" then return "<b>A</b>"
              else return rawData.grade
        }
        {
          sTitle: "Created"
          mData: "createdAt"
          mRender: ( dataSource, call, rawData ) ->
            rawData.createdAt ?= ""
            if rawData.createdAt
              return moment( rawData.createdAt ).fromNow()
            else return rawData.createdAt
        }
        {
          sTitle: "Counter"
          mData: "counter"
        }
      ]
      selector: "dataTable-browsers"
      # ## Collection
      #   * the collection these documents come from, must be the same as the server collection
      collection: Browsers
      # ## Subscription
      #   * the datatables publication providing the data on the server
      subscription: "a_browsers"
      # ## Query
      #   * the initial filter on the dataset
      query:
        grade: "A"
    return browsers