# jQuery DataTables [![Build Status](https://travis-ci.org/LumaPictures/meteor-jquery-datatables.svg?branch=dev)](https://travis-ci.org/LumaPictures/meteor-jquery-datatables)
### Sort, page, and filter millions of records.
#### Reactively.

This package wraps the powerful and mature DataTables.net jQuery plugin for enhancing HTML tables.

## DataTables.net features

* Variable length pagination
* On-the-fly filtering
* Multi-column sorting with data type detection
* Smart handling of column widths
* Display data from almost any data source
* Scrolling options for table viewport
* Fully internationalisable
* jQuery UI [ThemeRoller](http://datatables.net/styling/themes) support
* Rock solid - backed by a suite of 2900 [unit tests](http://datatables.net/development/testing)
* Wide variety of plug-ins inc. Editor, TableTools, FixedColumns and more

## [Live Example](http://jquery-datatables.meteor.com)

## Local Example

The first time your run the example app it will take a minute or two to start, this is because the example is writing
100k documents to the Browsers collection as an example dataset. You can change this [here](https://github.com/LumaPictures/meteor-jquery-datatables/blob/master/example/lib/browsers.coffee).


```
$ git clone https://github.com/lumapictures/meteor-jquery-datatables
$ cd meteor-jquery-datatables/example
$ mrt add jquery-datatables
$ meteor
```

## Local Tests
```
$ git clone https://github.com/lumapictures/meteor-jquery-datatables
$ cd meteor-jquery-datatables/example
$ mrt add jquery-datatables
$ meteor test-packages jquery-datatables
```

## Usage

All you have to do is include the datatable component in one of your templates like so:

```html
{{> dataTable
    columns=browsers.columns
    options=browsers.options
    subscription=browsers.subscription
    query=browsers.query
    debug="all"
}}
```

Then setup the data in your controller or as template helpers:

```coffeescript
Template.dataSources.browsers = -> return {
  columns: [{
    title: "Engine"
    data: "engine"
  },{
    title: "Browser"
    data: "browser"
  },{
    title: "Platform"
    data: "platform"
  },{
    title: "Version"
    data: "version"
  },{
    title: "Grade"
    data: "grade"
    mRender: ( data, type, row ) ->
      row ?= ""
      switch row.grade
        when "A" then return "<b>A</b>"
        else return row.grade
  },{
    title: "Created"
    data: "createdAt"
    mRender: ( data, type, row ) ->
      row.createdAt ?= ""
      if row.createdAt
        return moment( row.createdAt ).fromNow()
      else return row.createdAt
  },{
    title: "Counter"
    data: "counter"
  }]
  # ## Subscription
  #   * the datatables publication providing the data on the server
  subscription: "all_browsers"
  # ## Query
  #   * the initial filter on the dataset
  query:
    grade: "A"
}
```

On the server side, you need to publish the data:

```coffeescript
if Meteor.isServer
  DataTable.debug = "all";
  DataTable.publish "all_browsers", Browsers
```

## Styling

This package DOES NOT PROVIDE ANY STYLES OR ASSETS intentionally.

If you would like some help styling datatables you can check out my `luma-ui` package or the DataTables.net official docs.

## [DataTables Official Site](https://datatables.net/)
## [License](https://github.com/lumapictures/meteor-jquery-datatables/LICENSE.md)
## [Annotated Source](http://lumapictures.github.io/meteor-jquery-datatables)

## Contributing
* [meteor-talk announcement discussion](https://groups.google.com/d/msg/meteor-talk/nhulj4Zh1fU/ju1J1Nq6_eQJ)
* [datatables.net forum announcement](https://datatables.net/forums/discussion/20525/annoucement-reactive-datatables-for-meteorjs)
