class @ExampleController extends PackageLayoutController
  data: ->
    @data.package =
      name: "jQuery DataTables"
      description: "Sort, page, and filter millions of records. Reactively."
      owner: "LumaPictures"
      repo: "meteor-jquery-datatables"
    super