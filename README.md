# Luma DataTables [![Build Status](https://travis-ci.org/LumaPictures/luma-datatables.svg?branch=dev)](https://travis-ci.org/LumaPictures/luma-datatables)
### Sort, page, and filter millions of records reactively.

This meteor package gives you the ability to page, sort, and filter your largest collections with ease.

All you have to do is include the datatable component in one of your templates like so:

```html
{{> dataTable
    selector=pages.selector
    columns=pages.columns
    rows=pages.rows
}}
```

This package DOES NOT PROVIDE ANY STYLES OR ASSETS intentionally.

If you would like some help styling datatables you can check out my `luma-ui` package or the awesome datatables official docs.

## [Annotated Source](http://lumapictures.github.io/luma-datatables)
## [Live Example](http://luma-datatables.meteor.com)
## [DataTables Docs](https://datatables.net/usage/)
## [TableTools Docs](https://datatables.net/extras/tabletools/)

By default this datatable component renders datatables using Twitter Bootstrap 3 markup.

You can change this by setting `Template.dataTable.defaultOptions.sDom` property.

## Installation
`$ mrt add luma-datatables` in your app

## Component Parameters
* `selector` String ( required )
    * The table selector for the dataTable instance you are creating.
    * Needs to be unique in the page scope or you will get datatable mulit-render error
* `options` Object ( optional )
    * Any additional options you would like merged with the defaults `_.defaults options, defaultOptions`
    * The datatables options object, see datatables docs for more info
    * The default options are listed below.
    * The default options can changed by setting `Template.dataTable.defaultOptions.yourDumbProperty`
* `columns` Array of Objects ( required )
    * The column definitions you are passing to the datatable component
    * This is where to map object properties to columns and their headers
    * This is where you define custom templates for rendering data in cells
* `table_template` String ( optional )
    * The name of table layout template that you want to render.
    * default is `default_table_template` found [here](lib/datatables.html)
    * You can set your default template by assigning the template name to `Template.datatable.defaultTemplate`
* `collection` Meteor Collection ( required )
    * This is the collection that house the documents your datatable is displaying
    * This collection must be defined on both the client and the server
* `subscription` String ( required )
    * The name of the subscription your datatables is paging, sorting, and filtering
    * This must be a datatable compatible publication ( for more info see Publishing below )
* `query` MongoDB Selector ( optional )
    * The initial filter for your datatable
    * You should attempt to narrow your selection as much as possbile to improve performance
    * The default query is `{}`
* `debug` String ( optional )
    * A handy option for granular debug logs
    * `true` logs all messages from datatables
    * Set debug to any string to only log messages that contain that string
    * Some useful debug settings are :
        * `rendered` logs the instantiated component on render
        * `destroyed` logs when the component is detroyed
        * `initialized` logs the inital state of the datatable after data is acquired
        * `options` logs the datatables options for that instantiated component
        * `fnServerData` logs each request to the server by the component

## Default Options
```coffeescript
Template.dataTable.defaultOptions =
  #===== Default Table
  # * Pagination
  # * Filtering
  # * Sorting
  # * Bootstrap3 Markup
  bJQueryUI: false
  bAutoWidth: true
  bDeferRender: true
  sPaginationType: "full_numbers"
  sDom: "<\"datatable-header\"fl><\"datatable-scroll\"rt><\"datatable-footer\"ip>"
  oLanguage:
    sSearch: "_INPUT_"
    sLengthMenu: "<span>Show :</span> _MENU_"
    sProcessing: "Loading"
    oPaginate:
      sFirst: "First"
      sLast: "Last"
      sNext: ">"
      sPrevious: "<"
  aoColumnDefs: []
  aaSorting: []
  aaData: []
  aoColumns: []
``

## Usage

Paging millions of records is serious business, and datatables abstracts away the complicated pub / sub logic and provides you with a `dataTable` component in your templatea and a matching `dataTable` publication on the server.

#### Static Data

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
@Browsers = new Meteor.Collection 'browsers'

if Meteor.isServer
  DataTable.debug = "true"
  DataTable.publish "all_browsers", Browsers

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

Calling `_ensureIndex` is necessary in order to sort and filter collections.

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

## Development

To develop this package locally just :

1. `$ git clone https://github.com/lumapictures/luma-datatables`
2. `$ cd luma-datatables/example`
3. `$ mrt add luma-datatables`
4. `$ meteor`