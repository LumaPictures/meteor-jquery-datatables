@Browsers = new Meteor.Collection 'browsers'

Browsers.allow
  insert: -> true
  update: -> true
  remove: -> true

@insertBrowsers = ( howManyBrowsers ) ->
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
  count = 0
  insertBrowser = ( x ) ->
    browser = browserList[ x % browserList.length ]
    browser.createdAt = new Date()
    Browsers.insert browser
    count++
  insertBrowser(x) for x in [1..howManyBrowsers]
  console.log( count + ' browsers inserted')

if Meteor.isServer
  Meteor.publish "all_browsers", -> Browsers.find()
  Meteor.startup ->
    if Browsers.find().count() is 0
      insertBrowsers(12)