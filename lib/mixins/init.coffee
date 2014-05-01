# ### DataTable Instance
DataTableMixins.Init =
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
    @setDataTable $(".#{ @getSelector() } table").dataTable( @getOptions() )

  # ##### initializeDisplayLength()
  initializeDisplayLength: ->
    unless $.select2
      $( ".#{ @getSelector() } .dataTables_length select" ).select2 minimumResultsForSearch: "-1"