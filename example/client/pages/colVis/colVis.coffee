Template.colVis.browsers = ->
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
    selector: "column-visibiltiy"
    # ## Subscription
    #   * the datatables publication providing the data on the server
    subscription: "a_browsers"
    options:
      sDom:"<\"datatable-header\"flC><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  return browsers