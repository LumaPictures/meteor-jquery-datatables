# # reactiveOptions

# ###### reactiveOptions.events()
Template.reactiveOptions.events
  "change #filter-platform": ( event, template ) ->
    query = Session.get "reactive-query"
    if event.val
      filter =
        platform:
          $regex: event.val
      _.extend( query, filter )
    else delete query.platform
    Session.set "reactive-query", query

  "change #filter-user-agent": ( event, template ) ->
    query = Session.get "reactive-query"
    if event.val
      filter =
        userAgent:
          $regex: event.val
      _.extend( query, filter )
    else delete query.userAgent
    Session.set "reactive-query", _.extend( query, filter )

  "change #filter-cookie-enabled": ( event, template ) ->
    query = Session.get "reactive-query"
    if event.val
      val = true if event.val is "true"
      val = false if event.val is "false"
      filter =
        cookieEnabled: val
      _.extend( query, filter )
    else delete query.cookieEnabled
    Session.set "reactive-query", _.extend( query, filter )

  "change #filter-browser-online": ( event, template ) ->
    query = Session.get "reactive-query"
    if event.val
      val = true if event.val is "true"
      val = false if event.val is "false"
      filter =
        onLine: val
      _.extend( query, filter )
    else delete query.onLine
    Session.set "reactive-query", _.extend( query, filter )


# ##### reactiveOptions.helpers()
Template.reactiveOptions.helpers
  selectOptions: -> return {
    allowClear: true
  }
  reactiveQuery: -> return Session.get "reactive-query"