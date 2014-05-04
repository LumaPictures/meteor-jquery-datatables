# #### `query` MongoDB Selector ( optional )
# The initial filter for your datatable.
# The default query is `{}`
# You should attempt to narrow your selection as much as possbile to improve performance.
DataTableMixins.Query =
  # ##### setQuery()
  setQuery: ( query ) ->
    Match.test query, Object
    @setData 'query', query
    @log 'query:set', query

  # ##### prepareQuery()
  prepareQuery: ->
    if @getCollection()
      unless @getQuery()
        @setQuery {}

  # ##### getQuery()
  getQuery: ->
    return @getData().query or false

  getQueryAsString: ->
    query = @getData().query
    if query is false then "" else EJSON.stringify @getData().query
