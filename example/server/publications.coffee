# Reactive Data Source
# ====================
RowsTable = new DataTableComponent
  subscription: "rows"
  collection: Rows
  debug: "userId"
  query: ( component ) ->
    component.log "userId", this.userId
    return {}

RowsTable.publish()

# * Calling `_ensureIndex` is necessary in order to sort and filter collections.
#   * [see mongod docs for more info](http://docs.mongodb.org/manual/reference/method/db.collection.ensureIndex/)
Meteor.startup ->
  Rows._ensureIndex { _id: 1 }, { unique: 1 }
  Rows._ensureIndex 'cookieEnabled': 1
  Rows._ensureIndex 'language': 1
  Rows._ensureIndex 'onLine': 1
  Rows._ensureIndex 'platform': 1
  Rows._ensureIndex 'userAgent': 1
  Rows._ensureIndex 'systemLanguage': 1
  Rows._ensureIndex createdAt: 1