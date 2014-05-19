# #### `rows` Array of Object ( optional )
# Can be used to display static data, or reactive client side data.
DataTableMixins.Rows =
  extended: ->
    if Meteor.isClient
      @include
        # ##### prepareRows()
        prepareRows: ->
          unless @data.rows
            @data.rows = []
          @addGetterSetter "data", "rows"

        # ##### getRows()
        getRows: ->
          if @$
            return @$().fnSettings().aoData or false
          else return @rows() or false

        # ##### getRowIndex()
        # Gets the datatable index of a row by mongo id.
        getRowIndex: ( _id ) ->
          index = false
          counter = 0
          rows = @getRows()
          checkIndex = ( row ) ->
            if row._data._id is _id
              index = counter
            counter++
          checkIndex row for row in rows
          return index