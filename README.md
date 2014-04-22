# Luma DataTables [![Build Status](https://travis-ci.org/LumaPictures/luma-datatables.svg?branch=dev)](https://travis-ci.org/LumaPictures/luma-datatables)
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

## [Live Example](http://luma-datatables.meteor.com)

## Usage

All you have to do is include the datatable component in one of your templates like so:

```html
{{> dataTable
    selector=browsers.selector
    columns=browsers.columns
    collection=browsers.collection
    options=browsers.options
    subscription=browsers.subscription
    query=browsers.query
}}
```

Then setup the data in your controller or as template helpers:

```js
if (Meteor.isClient)
  Template.home.browsers = {
    columns: [
      {
        sTitle: "Engine",
        mData: "engine"
      },
      {
        sTitle: "Browser",
        mData: "browser"
      },
      {
        sTitle: "Platform",
        mData: "platform"
      },
      {
        sTitle: "Version",
        mData: "version",
        sClass: "center"
      },
      {
        sTitle: "Grade",
        mData: "grade",
        sClass: "center",
        mRender: function (dataSource, call, rawData) {
          if (rawData == null) rawData = "";
          switch rawData.grade
            when "A" then return "<b>A</b>"
            else return rawData.grade
          if (rawData.grade === "A") return "<b>A</b>";
          return rawData.grade;
        }
      },
      {
        sTitle: "Created",
        mData: "createdAt",
        mRender: function (dataSource, call, rawData) {
          if (rawData.createdAt == null) rawData.createdAt = "";
          if (rawData.createdAt)
            return moment(rawData.createdAt).fromNow()
          else 
            return rawData.createdAt || "";
      },
      {
        sTitle: "Counter",
        mData: "counter"
      }
    ],
    selector: "dataTable-browsers",
    collection: Browsers,
    subscription: "all_browsers",
    options: {
      oLanguage: {
        sProcessing: "You must construct additional pylons!"
      }  
    },    
    query: {
      grade: "A"
    }  
  }
```

On the server side, you need to publish the data:

```js
if (Meteor.isServer) {
  DataTable.debug = "true";
  DataTable.publish("all_browsers", Browsers);
}
```

## Styling

This package DOES NOT PROVIDE ANY STYLES OR ASSETS intentionally.

If you would like some help styling datatables you can check out my `luma-ui` package or the DataTables.net official docs.

## [DataTables Docs](https://datatables.net/usage/)
## [TableTools Docs](https://datatables.net/extras/tabletools/)
## [License](https://github.com/lumapictures/luma-datatables/LICENSE.md)
## [Annotated Source](http://lumapictures.github.io/luma-datatables)

## Contributing
* [meteor-talk announcement discussion](https://groups.google.com/d/msg/meteor-talk/nhulj4Zh1fU/ju1J1Nq6_eQJ)
* [datatables.net forum announcement](https://datatables.net/forums/discussion/20525/annoucement-reactive-datatables-for-meteorjs)