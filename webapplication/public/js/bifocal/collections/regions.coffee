define [
    'underscore', 'backbone',
    'bifocal/models/region'
], (_, Backbone, Region) ->

    Regions = Backbone.Collection.extend {
        model: Region
    }

    return Regions
