class @ExampleController extends PageController
  onBeforeAction: -> super
  onAfterAction: -> super
  action: -> super if @ready()
  waitOn: -> return [
    Meteor.subscribe "all_pages"
    Meteor.subscribe "all_browsers"
  ]
  data: ->
    self = @
    if self.ready()
      self.data.pages =
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
        ]
        rows: Pages.find()

      self.data.table =
        columns: [
          {
            sTitle: "id"
            mData: "_id"
            bVisible: false
          }
          {
            sTitle: "Engine"
            mData: "engine"
            mRender: ( dataSource, call, rawData ) -> rawData.engine ?= ""
          }
          {
            sTitle: "Browser"
            mData: "browser"
            mRender: ( dataSource, call, rawData ) -> rawData.browser ?= ""
          }
          {
            sTitle: "Platform"
            mData: "platform"
            mRender: ( dataSource, call, rawData ) -> rawData.platform ?= ""
          }
          {
            sTitle: "Version"
            mData: "version"
            sClass: "center"
            mRender: ( dataSource, call, rawData ) -> rawData.version ?= ""
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
        rows: Browsers.find()
    super