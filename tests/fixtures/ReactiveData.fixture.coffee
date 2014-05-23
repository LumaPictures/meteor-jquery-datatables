@Reactive = new Meteor.Collection "reactive"

if Meteor.isClient
  Session.setDefault "reactive-query", {}
  @ReactiveData =
    id: "ReactiveData"
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
    subscription: "reactive"
    # ## Query
    #   * the initial filter on the dataset
    query: Session.get "reactive-query"
    options:
      order:
        [ 5, 'desc' ]

if Meteor.isServer
  @ReactiveData =
    id: "ReactiveTable"
    subscription: "reactive"
    collection: Reactive

  rowCount = 20

  # * for the purposes of this example all changes to `Rows` are allowed
  Reactive.allow
    insert: -> true
    update: -> true
    remove: -> true

@insertRow = ( i ) ->
  if Meteor.isServer
    navigator =
      platform: "NodeJS"
      language: "en-us"
  if Meteor.isClient
    navigator = _.pick window.navigator, "cookieEnabled", "language", "onLine", "platform", 'userAgent', "systemLanguage"
    console.log "Inserting Row", navigator
  Reactive.insert _.extend navigator, createdAt: new Date()

@insertRows = ( howManyRows ) ->
  insertRow i for i in [ 1..howManyRows ]
  console.log "#{ howManyRows } rows inserted"

if Meteor.isServer
  # * initialize Rows collection
  Meteor.startup ->
    if Reactive.find().count() is 0
      console.log "Initializing #{ rowCount } rows"
      insertRows rowCount