# #### `selector` String ( required )
# The table selector for the dataTable instance you are creating, must be unique in the page scope or you will get
# datatable mulit-render error.
DataTableMixins.Selector =
  setSelector: ( selector ) ->
    Match.test selector, String
    @setData 'selector', selector
    @log 'selector:set', selector

  # ##### getSelector()
  getSelector: ->
    return @getData().selector or false

  # ##### prepareSelector()
  prepareSelector: ->
    unless @getSelector()
      @setSelector "datatable-#{ @getGuid() }"