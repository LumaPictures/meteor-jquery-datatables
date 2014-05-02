# #### `options` Object ( optional )
# `options` are additional options you would like merged with the defaults `_.defaults options, defaultOptions`.
# For more information on available dataTable options see the [DataTables Docs](https://datatables.net/usage/).
# The default options are listed below and can be changed by setting `Template.dataTable.defaultOptions.yourDumbProperty`
# ##### [DataTables Options Full Reference](https://datatables.net/ref)
DataTableMixins.Options =
  # ##### setOptions()
  setOptions: ( options ) ->
    Match.test options, Object
    @setData 'options', options
    @log "options:set", options

  # ##### getOptions()
  getOptions: ->
    return @getData().options or @presetOptions() or false

  # ##### prepareOptions()
  # Prepares the datatable options object by merging the options passed in with the defaults.
  prepareOptions: ->
    options = @getOptions() or {}
    options.component = @
    unless @isDomSource()
      options.aaData = @getRows() or []
      options.aoColumns = @getColumns() or []
      # If the componet was declared with a collection and a query it is setup as a reactive datatable.
      if @getSubscription()
        options.bServerSide = true
        options.bProcessing = true
        # `options.sAjaxSource` is currently useless, but is passed into `fnServerData` by datatables.
        options.sAjaxSource = "useful?"
        # This binds the datatables `fnServerData` server callback to this component instance.
        # `_.debounce` is used to prevent unneccesary subcription calls while typing a search
        options.fnServerData = _.debounce( @fnServerData.bind( @ ), 300 )
    @setOptions _.defaults( options, @defaultOptions )