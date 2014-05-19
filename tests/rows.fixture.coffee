@Rows = new Meteor.Collection "rows"

if Meteor.isClient
  @RowsData =
    id: "RowsData"
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
    }]
    # ## Subscription
    #   * the datatables publication providing the data on the server
    subscription: "rows"
    # ## Query
    #   * the initial filter on the dataset
    query: {}
    options:
      order:
        [ 5, 'desc' ]

if Meteor.isServer
  @RowsData =
    id: "RowsTable"
    subscription: "rows"
    collection: Rows