# # reactiveQuery

Template.reactiveQuery.rendered = -> $( "#filter-created" ).uniform()

# ###### reactiveQuery.events()
Template.reactiveQuery.events
  "click .add-row": ( event, template ) -> insertRow()
  
  "change #filter-platform": ( event, template ) ->
    query = Session.get "reactive-query"
    if _.isArray( event.val ) and event.val.length > 0
      $in = []
      event.val.forEach ( val ) -> $in.push val
      filter = platform: $in: $in
      _.extend( query, filter )
    else delete query.platform
    console.log query
    Session.set "reactive-query", query

  "keyup #filter-user-agent": _.debounce ( event, template ) ->
    query = Session.get "reactive-query"
    if event.target.value
      filter =
        userAgent:
          $regex: event.target.value
          $options: "i"
      _.extend( query, filter )
    else delete query.userAgent
    Session.set "reactive-query", query
  , 300

  "change #filter-cookie-enabled": ( event, template ) ->
    query = Session.get "reactive-query"
    if event.val
      val = true if event.val is "true"
      val = false if event.val is "false"
      filter =
        cookieEnabled: val
      _.extend query, filter
    else delete query.cookieEnabled
    Session.set "reactive-query", query

  "change #filter-created": ( event, template ) ->
    query = Session.get "reactive-query"
    if event.target.checked
      filter =
        createdAt: $gte: moment().startOf( "day").toDate()
      _.extend( query, filter )
    else delete query.createdAt
    Session.set "reactive-query", query


# ##### reactiveQuery.helpers()
Template.reactiveQuery.helpers
  filterPlatformOptions: -> return {
    placeholder: "Filter Platforms..."
  }
  selectOptions: -> return {
    allowClear: true
  }
  reactiveQuery: -> return Session.get "reactive-query"