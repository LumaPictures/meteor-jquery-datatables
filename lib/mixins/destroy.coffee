DataTableMixins.Destroy =
  destroy: ->
    if $(".ColVis_collection") then $(".ColVis_collection").remove()