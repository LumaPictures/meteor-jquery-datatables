#### Reactive Server Data

Place the following component in one of your templates.

```html
{{> dataTable
    selector=browsers.selector
    columns=browsers.columns
    collection=browsers.collection
    subscription=browsers.subscription
    query=browsers.query
    debug="true"
}}
```

You must also setup a Datatables publication on the server.

```coffeescript
if Meteor.isServer
  DataTable.debug = "true"
  DataTable.publish "all_browsers", Browsers
```

Calling `_ensureIndex` is necessary in order to sort and filter collections.

```coffeescript
  Meteor.startup ->
    Browsers._ensureIndex { _id: 1 }, { unique: 1 }
    Browsers._ensureIndex engine: 1
    Browsers._ensureIndex browser: 1
    Browsers._ensureIndex platform: 1
    Browsers._ensureIndex version: 1
    Browsers._ensureIndex grade: 1
    Browsers._ensureIndex createdAt: 1
    Browsers._ensureIndex counter: 1
```

Make sure the required data exists in the template context by setting it via template properties.

```coffeescript
Template.home.browsers = ->
  browsers =
    columns: [
      {
        sTitle: "Engine"
        mData: "engine"
      }
      {
        sTitle: "Browser"
        mData: "browser"
      }
      {
        sTitle: "Platform"
        mData: "platform"
      }
      {
        sTitle: "Version"
        mData: "version"
        sClass: "center"
      }
      {
        sTitle: "Grade"
        mData: "grade"
        sClass: "center"
        mRender: ( dataSource, call, rawData ) ->
          rawData ?= ""
          switch rawData.grade
            when "A" then return "<b>A</b>"
            else return rawData.grade
      }
      {
        sTitle: "Created"
        mData: "createdAt"
        mRender: ( dataSource, call, rawData ) ->
          rawData.createdAt ?= ""
          if rawData.createdAt
            return moment( rawData.createdAt ).fromNow()
          else return rawData.createdAt
      }
      {
        sTitle: "Counter"
        mData: "counter"
      }
    ]
    selector: "dataTable-browsers"
    collection: Browsers
    subscription: "all_browsers"
  return browsers
```

You can also set the properties in an `iron-router` controller ( this is what I do in all my apps ) and pass it into the page via Iron Router's `data` method.

```coffeescript
class YourDumbController extends RouteController
    data: ->
        browsers =
            columns: [
              {
                sTitle: "Engine"
                mData: "engine"
              }
              {
                sTitle: "Browser"
                mData: "browser"
              }
              {
                sTitle: "Platform"
                mData: "platform"
              }
              {
                sTitle: "Version"
                mData: "version"
                sClass: "center"
              }
              {
                sTitle: "Grade"
                mData: "grade"
                sClass: "center"
                mRender: ( dataSource, call, rawData ) ->
                  rawData ?= ""
                  switch rawData.grade
                    when "A" then return "<b>A</b>"
                    else return rawData.grade
              }
              {
                sTitle: "Created"
                mData: "createdAt"
                mRender: ( dataSource, call, rawData ) ->
                  rawData.createdAt ?= ""
                  if rawData.createdAt
                    return moment( rawData.createdAt ).fromNow()
                  else return rawData.createdAt
              }
              {
                sTitle: "Counter"
                mData: "counter"
              }
            ]
            selector: "dataTable-browsers"
            collection: Browsers
            subscription: "all_browsers"
        return {
            browsers: browsers
        }
```

Datatables doesn't care where the data comes from, as long as it is available in the template you defined the component in.