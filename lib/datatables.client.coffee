# DataTable Client
# ================
# ##### Extending the Template
# `Template.dataTable` is extended with `DataTableComponent`'s methods so that the template callbacks can execute
# `DataTableComponent` instance methods. In truth `Template.dataTable` is the actual `DataTableComponent`.

# ##### created()
# This is the component constructor.
Template.dataTable.created = -> new DataTableComponent @

# ##### rendered()
Template.dataTable.rendered = -> @rendered()

# ##### destroyed()
Template.dataTable.destroyed = -> @destroyed()