class @ExampleController extends PageController
  onBeforeAction: -> super
  onAfterAction: -> super
  action: -> super
  data: ->
    @data.table =
      columns: [
        {
          sTitle: "Engine"
        }
        {
          sTitle: "Browser"
        }
        {
          sTitle: "Platform"
        }
        {
          sTitle: "Version"
          sClass: "center"
        }
        {
          sTitle: "Grade"
          sClass: "center"
          fnRender: (obj) ->
            sReturn = obj.aData[obj.iDataColumn]
            sReturn = "<b>A</b>"  if sReturn is "A"
            sReturn
        }
      ]
      rows: []
    super