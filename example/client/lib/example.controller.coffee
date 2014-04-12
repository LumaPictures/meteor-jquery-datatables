class @ExampleController extends PageController
  onBeforeAction: -> super
  onAfterAction: -> super
  action: -> super if @ready()
  waitOn: -> return [
    Meteor.subscribe "all_pages"
    Meteor.subscribe "all_browsers"
  ]
  data: ->
    router = @
    if router.ready()
      router.data.pages =
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
          }
          {
            sTitle: "Title"
            mData: 'page.title'
          }
          {
            sTitle: "Subtitile"
            mData: 'page.subtitle'
          }
        ]
        selector: "datatable"
        rows: Pages.find().fetch()

      router.data.browsers =
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
        ]
        selector: "dataTable-browsers"
        collection: Browsers
    super