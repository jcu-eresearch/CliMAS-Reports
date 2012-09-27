define [
    'jquery', 'underscore', 'backbone',
    'bifocal/collections/regions'
    'bifocal/collections/regiontypes'
], ($, _, Backbone, Regions, RegionTypes) ->

    AppView = Backbone.View.extend {

        initialize: () ->
            # window.region_list initialised in the HAML template
            @region_types = new RegionTypes window.region_type_list
            @regions = new Regions window.region_list


        render: () ->

            me = this

            type_choices = []

            @region_types.each (r) ->
                type_choices.push AppView.type_choice(r.attributes)

            @$el.append $(AppView.type_chooser type_choices.join())

            @$el.append $("<br>")

            @regions.each (r) ->
                me.$el.append r.get("name")
                me.$el.append $("<br>")

            $('body').prepend @$el


    },{
        # templates here

        type_chooser: _.template """
            region type chooser
        """

        type_choice: _.template """
            region type
        """

    }

    return AppView
