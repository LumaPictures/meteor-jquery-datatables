# Component Parameters
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