define [
    'underscore', 'backbone',
    'bifocal/models/regiontype'
], (_, Backbone, RegionType) ->

    RegionTypes = Backbone.Collection.extend {
        model: RegionType
    }

    return RegionTypes
