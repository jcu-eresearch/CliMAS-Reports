require.config {
    baseUrl: '/js'
    waitSeconds: 30
    paths:
        jquery: 'lib/jquery-1.8.2.min'
        underscore: 'lib/underscore-min.AMD'
        backbone: 'lib/backbone-min.AMD'
}

require [
    'jquery'
    'bifocal/views/app'
], ($, AppView) ->

    $ ->
        appview = new AppView()
        appview.render()
