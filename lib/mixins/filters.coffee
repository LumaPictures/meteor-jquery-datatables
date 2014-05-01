DataTableMixins.Filters =
  # ##### initializeFilters()
  initializeFilters: ->
    @initializeFilterPlaceholder()
    @initializeFooterFilter()

  # ##### initializeFilterPlaceholder()
  initializeFilterPlaceholder: ->
    $(".#{ @getSelector() } .dataTables_filter input[type=text]").attr "placeholder", "Type to filter..."

  # ##### prepareFooterFilter()
  initializeFooterFilter: ->
    selector = @getSelector()
    if selector is 'datatable-add-row' and $.keyup
      self = @
      $(".#{ selector } .dataTables_wrapper tfoot input").keyup ->
        target = @
        self.getDataTable().fnFilter target.value, $(".#{ self.getSelector() } .dataTables_wrapper tfoot input").index( target )