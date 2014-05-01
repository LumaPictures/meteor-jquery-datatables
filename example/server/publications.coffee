# Reactive Data Source
# ====================
DataTable.debug = "all"
DataTable.publish "a_browsers", Browsers

# * Calling `_ensureIndex` is necessary in order to sort and filter collections.
#   * [see mongod docs for more info](http://docs.mongodb.org/manual/reference/method/db.collection.ensureIndex/)
Meteor.startup ->
  Browsers._ensureIndex { _id: 1 }, { unique: 1 }
  Browsers._ensureIndex engine: 1
  Browsers._ensureIndex browser: 1
  Browsers._ensureIndex platform: 1
  Browsers._ensureIndex version: 1
  Browsers._ensureIndex grade: 1
  Browsers._ensureIndex createdAt: 1
  Browsers._ensureIndex counter: 1