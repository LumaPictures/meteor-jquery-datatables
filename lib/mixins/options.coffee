# #### `options` Object ( optional )
# `options` are additional options you would like merged with the defaults `_.defaults options, defaultOptions`.
# For more information on available dataTable options see the [DataTables Docs](https://datatables.net/usage/).
# The default options are listed below and can be changed by setting `Template.dataTable.defaultOptions.yourDumbProperty`
# ##### [DataTables Options Full Reference](https://datatables.net/ref)
DataTableMixins.Options =
  defaultOptions:
    bJQueryUI: false
    bAutoWidth: true
    bDeferRender: false
    sPaginationType: "full_numbers"
    # ##### Bootstrap 3 Markup
    # You can change this by setting `Template.dataTable.defaultOptions.sDom` property.
    # For some example Less / CSS styles check out [luma-ui's dataTable styles](https://github.com/LumaPictures/luma-ui/blob/master/components/dataTables/dataTables.import.less)
    sDom: "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
    oLanguage:
      sSearch: "_INPUT_"
      sLengthMenu: "<span>Show :</span> _MENU_"
      # ##### Loading Message
      # Set `oLanguage.sProcessing` to whatever you want, event html. I haven't tried a Meteor template yet, could be fun!
      sProcessing: "Loading"
      oPaginate:
        sFirst: "First"
        sLast: "Last"
        sNext: ">"
        sPrevious: "<"

  # ##### setOptions()
  setOptions: ( options ) ->
    Match.test options, Object
    @setData 'options', options
    @log "options:set", options

  # ##### getOptions()
  getOptions: ->
    console.log @
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
      if @getCollection() and @getQuery()
        options.bServerSide = true
        options.bProcessing = true
        # `options.sAjaxSource` is currently useless, but is passed into `fnServerData` by datatables.
        options.sAjaxSource = "useful?"
        # This binds the datatables `fnServerData` server callback to this component instance.
        # `_.debounce` is used to prevent unneccesary subcription calls while typing a search
        options.fnServerData = _.debounce( @fnServerData.bind( @ ), 300 )
    @setOptions _.defaults( options, @defaultOptions )