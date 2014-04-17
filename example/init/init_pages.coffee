if Meteor.isServer
  Meteor.startup ->
    if Pages.find().count() is 0
      pageList = [{
        route: 'home'
        path: '/'
        controller: 'PageController'
        page:
          title: "jQuery DataTables"
          subtitle: "Sort, page, and filter millions of records reactively."
      }]
      count = 0
      _.each pageList, (page) ->
        Pages.insert page
        count++
      console.log( count + ' pages inserted')