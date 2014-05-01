# #### `table_template` String ( optional )
# The name of table layout template that you want to render.
# Default is `default_table_template` found [here](lib/datatables.html).
# You can set your default template by assigning the template name to `Template.datatable.defaultTemplate`.
DataTableMixins.TableTemplate =
  # ##### Default Table Template
  # The default table template is defined in datatables.html.
  defaultTemplate: 'default_table_template'

  # ##### chooseTemplate Helper
  # Return the template specified in the component parameters
  chooseTemplate: ( table_template = null ) ->
    # Set table template to default if no template name is passed in
    table_template ?= Template.dataTable.defaultTemplate
    # If the template is defined return it
    if Template[ table_template ]
      return Template[ table_template ]
      # Otherwise return the default template
    else return Template[ @defaultTemplate ]