Template.colVis.browsers = ->
  browsers =
    columns: [
      {
        title: "Engine"
        data: "engine"
      }
      {
        title: "Browser"
        data: "browser"
      }
      {
        title: "Platform"
        data: "platform"
      }
      {
        title: "Version"
        data: "version"
      }
      {
        title: "Grade"
        data: "grade"
        mRender: ( data, type, row ) ->
          row ?= ""
          switch row.grade
            when "A" then return "<b>A</b>"
            else return row.grade
      }
      {
        title: "Created"
        data: "createdAt"
        mRender: ( data, type, row ) ->
          row.createdAt ?= ""
          if row.createdAt
            return moment( row.createdAt ).fromNow()
          else return row.createdAt
      }
      {
        title: "Counter"
        data: "counter"
      }
    ]
    selector: "column-visibiltiy"
    # ## Collection
    #   * the collection these documents come from, must be the same as the server collection
    collection: Browsers
    # ## Subscription
    #   * the datatables publication providing the data on the server
    subscription: "a_browsers"
    options:
      dom:"<\"datatable-header\"flC><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  return browsers