# DataTable Component

## [DataTables Docs](https://datatables.net/usage/)
## [TableTools Docs](https://datatables.net/extras/tabletools/)

## Params
* `selector` [string] [required]
    * The table selector for the dataTable instance you are creating.
    * Needs to be unique in the page scope or you will get datatable mulit-render error
* `context` [array] [required]
    * The data context for the dataTable instance you are creating.
    * Can be an empty array, but cannot be null
* `table_template` [string]
    * The name of table layout template that you want to render.
    * default is `default_table_template`

## Example
#### Defaults
```html
{{> dataTable selector="datatable-tasks" context=data.tasks }}
```
#### Custom
```html
{{> dataTable selector="datatable-tasks" context=data.tasks table_template="tasks_table" }}
```