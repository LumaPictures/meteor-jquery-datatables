@Reactive = new Meteor.Collection "reactive"

# * Calling `_ensureIndex` is necessary in order to sort and filter collections.
#   * [see mongod docs for more info](http://docs.mongodb.org/manual/reference/method/db.collection.ensureIndex/)
Meteor.startup ->
  Reactive._ensureIndex { _id: 1 }, { unique: 1 }
  Reactive._ensureIndex 'cookieEnabled': 1
  Reactive._ensureIndex 'language': 1
  Reactive._ensureIndex 'onLine': 1
  Reactive._ensureIndex 'platform': 1
  Reactive._ensureIndex 'userAgent': 1
  Reactive._ensureIndex 'systemLanguage': 1
  Reactive._ensureIndex createdAt: 1

if Meteor.isClient
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
    query: {}
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