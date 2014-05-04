Template.colReorder.browsers = ->
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
        sClass: "center"
      }
      {
        title: "Grade"
        data: "grade"
        sClass: "center"
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
    # ## Subscription
    #   * the datatables publication providing the data on the server
    subscription: "a_browsers"
    options:
      dom:"<\"datatable-header\"flR><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  return browsers