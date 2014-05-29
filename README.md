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

`{{> DataTable browsers }}`

Then setup the data in your controller or as template helpers:

```coffeescript
Template.<yourTemplate>.browsers = -> return {
  
  # ## Id
  #   * While not required, setting a unique table id makes external manipulation possible through jquery
  id: "my-unique-table-id"
  
  # ## Columns
  #   * Map your dataset to columns you want displayed
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
  },{
    title: "Created"
    data: "createdAt"
    mRender: ( data, type, row ) -> return moment( row.createdAt ).fromNow()
  },{
    title: "Counter"
    data: "counter"
  }]
  
  # ## Subscription
  #   * the datatables publication providing the data on the server
  subscription: "all_browsers"
  
  # ## Query
  #   * the initial client filter on the dataset
  query:
    grade: "A"
}
```

### Reactive Query

The query parameter for reactive tables is now reactive ( duh ). My goal was to have the table impose no structure on the query and just use raw mongoDB selector.

The basic idea is that you set a session variable ( or some other reactive datasource ) to your initial query and then use that var as the query parameter for the table component. Whenever the query parm changes the table will automagically rerender using the new query to fetch its dataset.

[ You can see a basic implementation of this here ](https://github.com/LumaPictures/meteor-jquery-datatables/blob/master/example/client/views/pages/examples/reactiveQuery/reactiveQuery.coffee#L9) In the [ example ](http://jquery-datatables.meteor.com/examples/reactive-query) the table controls just extend the query object with whatever value they are set to. I tried to include examples of all the common control types, but if you think of any that I missed feel free to let me know.

Currently applying the filter can cause a somewhat janky table reload depending on what its contents looks like, this is something I plan on addressing ASAP.

### Publishing Data

On the server side, you need to publish the data:

```coffeescript
if Meteor.isServer
  RowsTable = new DataTableComponent
    subscription: "rows"
    collection: Rows
  
  RowsTable.publish()
```

### Limit Client Data Access

If you would like to limit the dataset published to the client simply append a query parameter to you the initialization object

```coffeescript
if Meteor.isServer
  RowsTable = new DataTableComponent
    
    subscription: "rows"
    
    collection: Rows
    
    # ##### Only return the rows created today
    query:
      createdAt: $gte: moment().startOf( "day").toDate()
  
  RowsTable.publish()
```

You can also set the query parameter to a function if you require access the the `this` context of the publication for things like user restricted access.

Query functions take the component as a parameter, so you still have access to the component context and all its instance methods.

```coffeescript
if Meteor.isServer
  RowsTable = new DataTableComponent
    
    subscription: "rows"
    
    collection: Rows
    
    # ##### Only return rows this user owns
    query: ( component ) ->
        component.log "userId", this.userId
        return { owner: this.userId }
    
    debug: "userId"

  RowsTable.publish()
```


## Event Binding

You can access the datatable after it has been initialized, it is stored in the data context of the instantiated datatable component. However this is not the best way to extend the tables features.

You have 3 main options ( going from simplest to most flexible )

1. simply attach events via jquery ( you must set id )

`{{> dataTable id="example" columns=pages.columns rows=pages.rows }}`

```coffeescript
$( '#example tbody' ).on 'click', 'tr', ->
  name = $( 'td', @ ).eq( 0 ).text()
  console.log "You clicked on #{ name }'s row"
```

The major drawback of this method is that you have to track the table state externally. Good for simple events, but I wouldn't recommend it for anything complex. 

2. Attach events through the initialization options

Set options in your controller or via a template helper

```coffeescript
options =
  initComplete: ->
    api = @api()
    api.$( 'td' ).click -> api.search( @innerHTML ).draw()
```

`{{> DataTable options=options columns=pages.columns rows=pages.rows }}`

Now datatables is handling the data for you. Here is a ton of api method example https://datatables.net/examples/api/

This option will cover most of your use cases.

## Styling

This package DOES NOT PROVIDE ANY STYLES OR ASSETS intentionally.

If you would like some help styling datatables you can check out my `luma-ui` package or the DataTables.net official docs.

## [DataTables Official Site](https://datatables.net/)
## [License](https://github.com/lumapictures/meteor-jquery-datatables/LICENSE.md)
## [Annotated Source](http://lumapictures.github.io/meteor-jquery-datatables)

## Contributing
* [meteor-talk announcement discussion](https://groups.google.com/d/msg/meteor-talk/nhulj4Zh1fU/ju1J1Nq6_eQJ)
* [datatables.net forum announcement](https://datatables.net/forums/discussion/20525/annoucement-reactive-datatables-for-meteorjs)
