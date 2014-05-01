# #### `columns` Array of Objects ( required )
# The column definitions you are passing to the datatable component. This is where to map object properties to columns
# and their headers. You can also define custom templates for rendering data in cells using the `mData` property.
DataTableMixins.Columns =
  # ##### setColumns()
  setColumns: ( columns ) ->
    Match.test columns, Array
    @setData 'columns', columns
    @log "columns:set", columns

  # ##### prepareColumns()
  prepareColumns: ->
    unless @isDomSource()
      columns = @getColumns() or []
      # Adds _id as a hidden column by default.
      columns.push
        sTitle: "id"
        mData: "_id"
        bVisible: false
        bSearchable: false
      # Sets a default cell render function for every column.
      @setDefaultCellValue column for column in columns
      @setColumns columns

  # ##### setDefaultCellValue()
  # The default cell render function defaults all cells to "" if undefined.
  setDefaultCellValue: ( column ) ->
    Match.test column.mData, String
    Match.test column.sTitle, String
    unless column.mRender
      column.mRender = ( dataSource, call, rawData ) ->
        rawData[ column.mData ] ?= ""

  # ##### getColumns()
  getColumns: ->
    return @getData().columns or false