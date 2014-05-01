# ## Utility Methods
DataTableMixins.Utility =
  # ##### getTemplateInstance()
  getTemplateInstance: ->
    return @templateInstance or false

  # ##### getGuid()
  getGuid: ->
    return @guid or false

  # ##### getData()
  getData: ->
    return @getTemplateInstance().data or false

  # ##### setData()
  setData: ( key, data ) ->
    @templateInstance.data[ key ] = data

  # ##### isDomSource()
  # returns true if the dataTable is backed by a table in the dom
  isDomSource: ->
    return @getData().dom is true or false

  # ##### arrayToDictionary()
  arrayToDictionary: ( array, key ) ->
    dict = {}
    dict[obj[key]] = obj for obj in array when obj[ key ]?
    dict