# Static Data

You can render static ( or client only ) data easily by setting the `rows` property to an array of objects

```html
{{> dataTable
    selector=pages.selector
    columns=pages.columns
    rows=pages.rows
}}
```

A simple datasource I used in the [example](example/client/example.coffee)

```coffeescript
Template.home.pages = ->
  pages =
    columns: [
      {
        sTitle: "Route"
        mData: "route"
      }
      {
        sTitle: "Path"
        mData: "path"
      }
      {
        sTitle: "Controller"
        mData: "controller"
      }
      {
        sTitle: "Title"
        mData: "page.title"
        mRender:  ( dataSource, call, rawData ) ->
          rawData.page.title ?= ""
      }
      {
        sTitle: "Subtitile"
        mData: "page.subtitle"
        mRender:  ( dataSource, call, rawData ) ->
          rawData.page.subtitle ?= ""
      }
    ]
    selector: "dataTable-pages"
    rows: Pages.find().fetch()
  return pages
```