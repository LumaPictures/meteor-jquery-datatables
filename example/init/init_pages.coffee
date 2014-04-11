if Meteor.isServer
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
        template: "datatables"
        path: "/tables/dataTables"
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
      }]
      count = 0
      _.each pageList, (page) ->
        Pages.insert page
        count++
      console.log( count + ' pages inserted')