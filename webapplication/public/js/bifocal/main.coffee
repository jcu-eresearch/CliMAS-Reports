
unless window.console
    window.console = { log: () -> {} }

require.config {
#    baseUrl: '/js'
    baseUrl: window.settings.siteUrlPrefix + 'js'
    waitSeconds: 30
    paths:
        jquery: 'lib/jquery-1.8.2.min'
        underscore: 'lib/underscore-min.AMD'
        backbone: 'lib/backbone-min.AMD'
        showdown: 'lib/showdown'
        ra: 'lib/ra'
}

require [
    'jquery'
    'bifocal/views/app'
], ($, AppView) ->

    $ ->
        appview = new AppView()
        appview.render()
