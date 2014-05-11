# ### DataTable Instance
DataTableMixins.Initialize =
  # ##### initialize()
  # Set the initial table properties from the component declaration, initialize the jQuery DataTables object, and initialize
  # other third parties if they exist ( plugins, select2, etc. )
  initialize: ->
    @initializeDataTable()
    @initializeFilters()
    @initializeDisplayLength()
    @log "initialized", @


  # ##### getDataTable()
  getDataTable: ->
    return @getData().dataTable or false

  # ##### setDataTable()
  setDataTable: ( dataTable ) ->
    Match.test dataTable, Object
    @setData 'dataTable', dataTable
    @log "dataTable:set", dataTable.fnSettings()

  # ##### prepareDataTable()
  initializeDataTable: ->
    @setDataTable $("##{ @getSelector() } table").dataTable( @getOptions() )

  # ##### initializeDisplayLength()
  initializeDisplayLength: ->
    unless $.select2
      $( "##{ @getSelector() } .dataTables_length select" ).select2 minimumResultsForSearch: "-1"