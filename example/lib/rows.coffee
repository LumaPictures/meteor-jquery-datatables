rowCount = 100000

# * Collection defined on server and client
@Rows = new Meteor.Collection 'rows'

# * for the purposes of this example all changes to `Rows` are allowed
Rows.allow
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
  Rows.insert _.extend navigator, createdAt: new Date()

@insertRows = ( howManyRows ) ->
  insertRow i for i in [ 1..howManyRows ]
  console.log "#{ howManyRows } rows inserted"

if Meteor.isServer
  # * initialize Rows collection
  Meteor.startup ->
    if Rows.find().count() is 0
      console.log "Initializing #{ rowCount } rows"
      insertRows rowCount