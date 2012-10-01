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

            console.log type_choices

            @$el.append AppView.type_chooser({ regiontypes: type_choices.join() })

            @$el.append $("<br>")

            @regions.each (r) ->
                me.$el.append r.get("name")
                me.$el.append $("<br>")

            $('body').prepend @$el


    },{
        # templates here

        type_chooser: _.template """
            <select>
            <%= regiontypes %>
            </select>
        """

        type_choice: _.template """
            <option><%= regiontypename %></option>
        """

    }

    return AppView
