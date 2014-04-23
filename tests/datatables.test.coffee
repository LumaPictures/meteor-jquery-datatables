if Meteor.isClient
  browserList = [
    {
      engine: "Trident"
      browser: "Internet Explorer 4.0"
      platform: "Win 95+"
      version: 4
      grade: "X"
    }
    {
      engine: "Trident"
      browser: "Internet Explorer 5.0"
      platform: "Win 95+"
      version: 5
      grade: "C"
    }
    {
      engine:  "Trident"
      browser: "Internet Explorer 5.5"
      platform: "Win 95+"
      version: 5.5
      grade: "A"
    }
    {
      engine: "Trident"
      browser: "Internet Explorer 6.0"
      platform: "Win 98+"
      version: 6
      grade: "A"
    }
    {
      engine: "Trident"
      browser: "Internet Explorer 7.0"
      platform: "Win XP SP2+"
      version: 7
      grade: "A"
    }
    {
      engine: "Gecko"
      browser: "Firefox 1.5"
      platform: "Win 98+ / OSX.2+"
      version: 1.8
      grade: "A"
    }
    {
      engine: "Gecko"
      browser: "Firefox 2"
      platform: "Win 98+ / OSX.2+"
      version: 1.8
      grade: "A"
    }
    {
      engine: "Gecko"
      browser: "Firefox 3"
      platform: "Win 2k+ / OSX.3+"
      version: 1.9
      grade: "A"
    }
    {
      engine: "Webkit"
      browser: "Safari 1.2"
      platform: "OSX.3"
      version: 125.5
      grade: "A"
    }
    {
      engine: "Webkit"
      browser: "Safari 1.3"
      platform: "OSX.3"
      version: 312.8
      grade: "A"
    }
    {
      engine: "Webkit"
      browser: "Safari 2.0"
      platform: "OSX.4+"
      version: 419.3
      grade: "A"
    }
    {
      engine: "Webkit"
      browser: "Safari 3.0"
      platform: "OSX.4+"
      version: 522.1
      grade: "A"
    }
  ]

  columns = [
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
        switch rawData.grade
          when "A" then return "<b>A</b>"
          else return rawData.grade

    }
  ]

  createDataTableStub = ( data ) ->
    instantiatedComponent = UI.renderWithData Template.dataTable, data
    fakeDOM = document.createElement 'div'
    UI.insert instantiatedComponent, fakeDOM
    return instantiatedComponent

  Tinytest.add "jQuery DataTables - defined on client", ( test ) ->
    test.notEqual $().dataTable, undefined, "Expected DataTable jQuery plugin to be defined on the client."
    test.notEqual Template.dataTable, undefined, "Expected Template.dataTable to be defined on the client."

  Tinytest.add "jQuery DataTables - default options", ( test ) ->
    test.notEqual Template.dataTable.defaultOptions, undefined, "Expected defaultOptions to be defined on the client."

  Tinytest.add "jQuery DataTables - chooseTemplate()", ( test ) ->
    test.notEqual Template[ Template.dataTable.defaultTemplate ], undefined, "Expected the default dataTable template to be defined."
    test.equal Template.dataTable.chooseTemplate(), Template[ Template.dataTable.defaultTemplate ], "Calling chooseTemplate without a param returns the default_table_template."
    test.notEqual Template.dataTable.chooseTemplate('undefined_template'), undefined, "chooseTemplate() should never return undefined."
    # stub some_template being defined
    Template['some_template'] = true
    test.equal Template.dataTable.chooseTemplate('some_template'), Template['some_template'], "Passing a template name to chooseTemplate() returns that template."
    try
      Template.dataTable.setDefaultTemplate 5
    catch error
      test.notEqual error, undefined, "Passing something other than a string to setDefaultTemplate() should throw an error."
    try
      Template.dataTable.setDefaultTemplate 'undefined_template'
    catch error
      test.notEqual error, undefined, "Trying to set the default template to an undefined template should throw an error."