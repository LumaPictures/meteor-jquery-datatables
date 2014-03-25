Meteor.startup ->
  if Pages.find().count() is 0
    pageList = [{
      route: 'home'
      path: '/'
      controller: 'ExampleController'
      page:
        title: "Home"
        subtitle: "This isn't really home, its work."
    },{
      route: "tables"
      path: "/tables"
      controller: 'ExampleController'
      nav:
        priority: 8
        icon: 'icon-table2'
        children: [{
          title: 'Static Tables'
          route: 'staticTables'
        },{
          title: 'Datatables'
          route: 'datatables'
        }]
      page:
        title: "Tables"
        subtitle: "Yo dawg, heard you like tables."
    },{
      route: "staticTables"
      path: "/tables/static"
      controller: 'ExampleController'
      page:
        title: "Static Tables"
        subtitle: "So good it doesn't have to change."
      breadcrumbs: [
        title: "Tables"
        route: 'tables'
      ]
    },{
      route: "datatables"
      path: "/tables/datatables"
      controller: 'ExampleController'
      page:
        title: "Datatables"
        subtitle: "Quick, responsive, and flexible."
      breadcrumbs: [
        title: "Tables"
        route: 'tables'
      ]
      defaultTable:
        columns: [
          {
            sTitle: "Engine"
          }
          {
            sTitle: "Browser"
          }
          {
            sTitle: "Platform"
          }
          {
            sTitle: "Version"
            sClass: "center"
          }
          {
            sTitle: "Grade"
            sClass: "center"
            fnRender: (obj) ->
              sReturn = obj.aData[obj.iDataColumn]
              sReturn = "<b>A</b>"  if sReturn is "A"
              sReturn
          }
        ]
        rows: [
          # Reduced data set
          [
            "Trident"
            "Internet Explorer 4.0"
            "Win 95+"
            4
            "X"
          ]
          [
            "Trident"
            "Internet Explorer 5.0"
            "Win 95+"
            5
            "C"
          ]
          [
            "Trident"
            "Internet Explorer 5.5"
            "Win 95+"
            5.5
            "A"
          ]
          [
            "Trident"
            "Internet Explorer 6.0"
            "Win 98+"
            6
            "A"
          ]
          [
            "Trident"
            "Internet Explorer 7.0"
            "Win XP SP2+"
            7
            "A"
          ]
          [
            "Gecko"
            "Firefox 1.5"
            "Win 98+ / OSX.2+"
            1.8
            "A"
          ]
          [
            "Gecko"
            "Firefox 2"
            "Win 98+ / OSX.2+"
            1.8
            "A"
          ]
          [
            "Gecko"
            "Firefox 3"
            "Win 2k+ / OSX.3+"
            1.9
            "A"
          ]
          [
            "Webkit"
            "Safari 1.2"
            "OSX.3"
            125.5
            "A"
          ]
          [
            "Webkit"
            "Safari 1.3"
            "OSX.3"
            312.8
            "A"
          ]
          [
            "Webkit"
            "Safari 2.0"
            "OSX.4+"
            419.3
            "A"
          ]
          [
            "Webkit"
            "Safari 3.0"
            "OSX.4+"
            522.1
            "A"
          ]
        ]
    }]
    count = 0
    _.each pageList, (page) ->
      Pages.insert page
      count++
    console.log( count + ' pages inserted')