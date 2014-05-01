###
  Drill Down Filter Widget
  ====================
  This column filter plugin is heavily inspired ( aka I copied his source and butchered it ) from
  the [ dataTables column filter plugin ](http://www.datatables.net/extras/thirdparty/ColumnFilterWidgets/DataTables/extras/ColumnFilterWidgets/)
###

###
  Menu-based filter widgets based on distinct column values for a table.
###
class ColumnFilterWidgets
  # @param oDataTableSettings Settings object for the target table.
  constructor: ( oDataTableSettings ) ->
    self = this
    sExcludeList = ""
    self.$WidgetContainer = $( "<div class=\"column-filter-widgets\"></div>" )
    self.$MenuContainer = self.$WidgetContainer
    self.$TermContainer = null
    self.aoWidgets = []
    self.sSeparator = ""
    if "oColumnFilterWidgets" of oDataTableSettings.oInit
      if "aiExclude" of oDataTableSettings.oInit.oColumnFilterWidgets
        sExcludeList = "|#{ oDataTableSettings.oInit.oColumnFilterWidgets.aiExclude.join( '|' ) }|"
      if "bGroupTerms" of oDataTableSettings.oInit.oColumnFilterWidgets
        if oDataTableSettings.oInit.oColumnFilterWidgets.bGroupTerms
          self.$MenuContainer = $( "<div class=\"column-filter-widget-menus\"></div>" )
          self.$TermContainer = $( "<div class=\"column-filter-widget-selected-terms\"></div>" ).hide()

    # Add a widget for each visible and filtered column
    $.each oDataTableSettings.aoColumns, ( i, oColumn ) ->
      $WidgetElem = $( "<div class=\"column-filter-widget\"></div>" )
      if sExcludeList.indexOf( "|#{ i }|" ) < 0
        self.aoWidgets.push new ColumnFilterWidget( $WidgetElem, oDataTableSettings, i, self )
        self.$MenuContainer.append $WidgetElem

    if self.$TermContainer
      self.$WidgetContainer.append self.$MenuContainer
      self.$WidgetContainer.append self.$TermContainer
    oDataTableSettings.aoDrawCallback.push
      name: "ColumnFilterWidgets"
      fn: ->
        $.each self.aoWidgets, ( i, oWidget ) ->
          oWidget.fnDraw()
    return self

  ###
    Get the container node of the column filter widgets.
  ###
  getContainer: ->
    @$WidgetContainer.get 0

###
  A filter widget based on data in a table column.
###
class ColumnFilterWidget
  ###
    @param {object} $Container The jQuery object that should contain the widget.
    @param {object} oSettings The target table's settings.
    @param {number} i The numeric index of the target table column.
    @param {object} widgets The ColumnFilterWidgets instance the widget is a member of.
  ###
  constructor: ( $Container, oDataTableSettings, i, widgets ) ->
    widget = this
    sTargetList = undefined
    widget.iColumn = i
    widget.oColumn = oDataTableSettings.aoColumns[i]
    widget.$Container = $Container
    widget.oDataTable = oDataTableSettings.oInstance
    widget.asFilters = []
    widget.sSeparator = ""
    widget.bSort = true
    widget.iMaxSelections = -1

    if "oColumnFilterWidgets" of oDataTableSettings.oInit
      if "sSeparator" of oDataTableSettings.oInit.oColumnFilterWidgets
        widget.sSeparator = oDataTableSettings.oInit.oColumnFilterWidgets.sSeparator
      if "iMaxSelections" of oDataTableSettings.oInit.oColumnFilterWidgets
        widget.iMaxSelections = oDataTableSettings.oInit.oColumnFilterWidgets.iMaxSelections
      if "aoColumnDefs" of oDataTableSettings.oInit.oColumnFilterWidgets
        $.each oDataTableSettings.oInit.oColumnFilterWidgets.aoColumnDefs, ( iIndex, oColumnDef ) ->
          sTargetList = "|#{ oColumnDef.aiTargets.join("|") }|"
          if sTargetList.indexOf( "|#{ i }|" ) >= 0
            $.each oColumnDef, ( sDef, oDef ) ->
              widget[ sDef ] = oDef

    widget.$Select = $( """<select multiple="multiple" tabindex="2"></select>""" ).addClass( "widget-" + widget.iColumn ).change ->
      sSelected = widget.$Select.val()
      sText = undefined
      $TermLink = undefined
      $SelectedOption = undefined
      # The blank option is a default, not a filter, and is re-selected after filtering
      return if sSelected is ""

      sText = $( "<div>" + sSelected + "</div>" ).text()
      $TermLink = $( "<a class=\"filter-term\" href=\"#\"></a>" )
      .addClass( "filter-term-" + sText.toLowerCase().replace( /\W/g, "" ) )
      .text( sText )
      .click ->
          # Remove from current filters array
          widget.asFilters = $.grep widget.asFilters, ( sFilter ) ->
            sFilter isnt sSelected
          $TermLink.remove()
          if widgets.$TermContainer and 0 is widgets.$TermContainer.find(".filter-term").length
            widgets.$TermContainer.hide()
          # Add it back to the select
          widget.$Select.append $( "<option></option>" ).attr( "value", sSelected ).text( sText )
          if widget.iMaxSelections > 0 and widget.iMaxSelections > widget.asFilters.length
            widget.$Select.attr "disabled", false
          widget.fnFilter()
          return false

      widget.asFilters.push sSelected
      if widgets.$TermContainer
        widgets.$TermContainer.show()
        widgets.$TermContainer.prepend $TermLink
      else
        widget.$Select.after $TermLink
      $SelectedOption = widget.$Select.children("option:selected")
      widget.$Select.val ""
      $SelectedOption.remove()
      if widget.iMaxSelections > 0 and widget.iMaxSelections <= widget.asFilters.length
        widget.$Select.attr "disabled", true
      widget.fnFilter()
    widget.$Container.append widget.$Select
    widget.fnDraw()

  ###
    Add backslashes to regular expression symbols in a string.

    Allows a regular expression to be constructed to search for
    variable text.
  ###
  @fnRegExpEscape: ( sText ) -> return sText.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"

  ###
    Perform filtering on the target column.
  ###
  fnFilter: ->
    widget = this
    asEscapedFilters = []
    sFilterStart = undefined
    sFilterEnd = undefined
    if widget.asFilters.length > 0
      # Filters must have RegExp symbols escaped
      $.each widget.asFilters, ( i, sFilter ) -> asEscapedFilters.push ColumnFilterWidget.fnRegExpEscape( sFilter )
      # This regular expression filters by either whole column values or an item in a comma list
      if widget.sSeparator
        sFilterStart = "(^|#{ widget.sSeparator })("
        sFilterEnd = ")(#{ + widget.sSeparator }|$)"
      else
        sFilterStart = "^("
        sFilterEnd = ")$"
      widget.oDataTable.fnFilter ( sFilterStart + asEscapedFilters.join( "|" ) + sFilterEnd ), widget.iColumn, true, false
    else
      # Clear any filters for this column
      widget.oDataTable.fnFilter "", widget.iColumn

  ###
    On each table draw, update filter menu items as needed. This allows any process to
    update the table's column visiblity and menus will still be accurate.
  ###
  fnDraw: ->
    widget = this
    oDistinctOptions = {}
    aDistinctOptions = []
    aData = undefined
    if widget.asFilters.length is 0
      # Find distinct column values
      aData = widget.oDataTable.fnGetColumnData widget.iColumn
      $.each aData, ( i, sValue ) ->
        if widget.sSeparator
          asValues = sValue.split new RegExp( widget.sSeparator )
        else asValues = [ sValue ]
        $.each asValues, ( j, sOption ) ->
          unless oDistinctOptions.hasOwnProperty(sOption)
            oDistinctOptions[ sOption ] = true
            aDistinctOptions.push sOption

      # Build the menu
      widget.$Select.empty().append $( "<option></option>" ).attr( "value", "" ).text widget.oColumn.sTitle
      if widget.bSort
        if widget.hasOwnProperty "fnSort"
          aDistinctOptions.sort widget.fnSort
        else
          aDistinctOptions.sort()
      $.each aDistinctOptions, ( i, sOption ) ->
        sText = undefined
        sText = $( "<div>#{ sOption }</div>" ).text()
        widget.$Select.append $( "<option></option>" ).attr( "value", sOption ).text sText

      if aDistinctOptions.length > 1
        # Enable the menu
        widget.$Select.attr "disabled", false
      else
        # One option is not a useful menu, disable it
        widget.$Select.attr "disabled", true

###
  * Function: fnGetColumnData
  * Purpose:  Return an array of table values from a particular column.
  * Returns:  array string: 1d data array
  * Inputs:   `oSettings` - dataTable settings object. This is always the last argument past to the function
  *           `iColumn` - the id of the column to extract the data from
  *           `bUnique` - optional - if set to false duplicated values are not filtered out
  *           `bFiltered` - optional - if set to false all the table data is used (not only the filtered)
  *           `bIgnoreEmpty` - optional - if set to false empty values are not filtered from the result array
###
$.fn.dataTableExt.oApi.fnGetColumnData = (
  oSettings,
  iColumn,
  bUnique = true,
  bFiltered = true,
  bIgnoreEmpty = true
) ->
  # check that we have a column id
  return new Array() if iColumn is undefined
  # list of rows which we're going to loop through
  aiRows = undefined
  # use only filtered rows
  if bFiltered
    aiRows = oSettings.aiDisplay
    # use all rows
  else aiRows = oSettings.aiDisplayMaster
  # set up data array
  asResultData = new Array()
  setResultData = ( i ) =>
    iRow = aiRows[ i ]
    sValue = @fnGetData iRow, iColumn
    # ignore empty values?
    unless bIgnoreEmpty is true and sValue.length is 0
      # ignore unique values?
      unless bUnique is true and jQuery.inArray( sValue, asResultData ) > -1
        # else push the value onto the result data array
        asResultData.push sValue
  setResultData i for i in [ 0..aiRows.length ]
  return asResultData