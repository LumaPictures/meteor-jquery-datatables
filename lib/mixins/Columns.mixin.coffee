# #### `columns` Array of Objects ( required )
# The column definitions you are passing to the datatable component. This is where to map object properties to columns
# and their headers. You can also define custom templates for rendering data in cells using the `mData` property.
DataTableMixins.Columns =
  extended: ->
    if Meteor.isClient
      @include
        # ##### prepareColumns()
        prepareColumns: ->
          unless @columns
            @data.columns = undefined
            @addGetterSetter "data", "columns"
          columns = @columns() or []
          # Sets a default cell render function for every column.
          @setDefaultCellValue column for column in columns
          @columns columns

        # ##### setDefaultCellValue()
        # The default cell render function defaults all cells to "" if undefined.
        setDefaultCellValue: ( column ) ->
          Match.test column.data, String
          Match.test column.title, String
          unless column.mRender
            column.mRender = ( data, type, row ) ->
              row[ column.data ] ?= ""