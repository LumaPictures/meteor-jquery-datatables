# DataTable Component [![Build Status](https://travis-ci.org/LumaPictures/component-dataTable.svg?branch=dev)](https://travis-ci.org/LumaPictures/component-dataTable)

## [Live Example](http://component-dataTable.meteor.com)
## [DataTables Docs](https://datatables.net/usage/)
## [TableTools Docs](https://datatables.net/extras/tabletools/)

## Installation
Add to `smart.json` `packages` object :

```javascript
"component-dataTable": {
    "git": "https://github.com/lumapictures/component-dataTable"
}
```

Then `$ mrt add component-dataTable` in your app

## Options
* `selector` [string] [required]
    * The table selector for the dataTable instance you are creating.
    * Needs to be unique in the page scope or you will get datatable mulit-render error
* `context` [array] [required]
    * The data context for the dataTable instance you are creating.
    * Can be an empty array, but cannot be null
* `table_template` [string]
    * The name of table layout template that you want to render.
    * default is `default_table_template`

## Usage

#### Defaults
```html
{{> dataTable selector="datatable-tasks" context=data.tasks }}
```
#### Custom
```html
{{> dataTable selector="datatable-tasks" context=data.tasks table_template="tasks_table" }}
```

## Development

To develop this package locally just :

1. `$ git clone https://github.com/lumapictures/component-dataTable`
2. `$ cd component-dataTable/example`
3. `$ mrt --force`
4. `$ meteor`