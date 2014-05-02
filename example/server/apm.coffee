Meteor.startup ->
  if Meteor.settings and Meteor.settings.private.apm
    apmAuth = Meteor.settings.private.apm
    Apm.connect apmAuth.appId, apmAuth.appSecret