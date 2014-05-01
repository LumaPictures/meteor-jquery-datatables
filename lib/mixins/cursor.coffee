# ### Cursor
#   The reactive cursor responsible for keeping the client in sync
#   identical to the server cursor publishing the data, except it does not skip
DataTableMixins.Cursor =
  # ##### setCursor()
  setCursor: ( cursor ) ->
    Match.test cursor, Object
    @setData 'cursor', cursor
    @log "cursor:set", cursor

  # ##### prepareCursor()
  prepareCursor: -> return

  # ##### getCursor()
  getCursor: -> return @getData().cursor or false