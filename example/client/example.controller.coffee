class @ExampleController extends PackageLayoutController
  data: ->
    @data.rows =
      columns: [{
        title: "Platform"
        data: "platform"
      },{
        title: "User Agent"
        data: "userAgent"
      },{
        title: "Cookies Enables"
        data: 'cookieEnabled'
      },{
        title: "Browser Language"
        data: "language"
      },{
        title: "Browser Online"
        data: "onLine"
      },{
        title: "Created"
        data: "createdAt"
        mRender: ( data, type, row ) ->
          return moment( row.createdAt ).fromNow()
      }]
      # ## Subscription
      #   * the datatables publication providing the data on the server
      subscription: "rows"
      # ## Query
      #   * the initial filter on the dataset
      query: {}
      debug: "all"
      options:
        order:
          [ 5, 'desc' ]

    @data.package =
      name: "jQuery DataTables"
      description: "Sort, page, and filter millions of records. Reactively."
      owner: "LumaPictures"
      repo: "meteor-jquery-datatables"
    super