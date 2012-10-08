define [
    'jquery', 'underscore', 'backbone', 'showdown',
    'bifocal/collections/regions'
    'bifocal/collections/regiontypes'
    'ra'
], ($, _, Backbone, Showdown, Regions, RegionTypes, RA) ->

    AppView = Backbone.View.extend {
        # ----------------------------------------------------------------
        events:
            'click .generate': 'startReport'
            'change select': 'changeRegion'
            'change input[type=radio].rtype': 'changeRegionType'
        # ----------------------------------------------------------------
        initialize: () ->
            # window.region_list initialised in the HAML template
            @region_types = new RegionTypes window.region_type_list
            @regions = new Regions window.region_list
            _.bindAll this
        # ----------------------------------------------------------------
        render: () ->

            me = this

            type_choices = []

            @region_types.each (rt) ->

                # make a list of that region type's regions
                region_list = []
                me.regions.each (r) ->
                    if r.get('region_type_regiontype') == rt.get('regiontype')
                        region_list.push AppView.region_choice(r.attributes)

                # merge the region list into the region type attributes
                info = _.extend({regions: region_list.join('')}, rt.attributes)
                type_choices.push AppView.type_choice(info)

            @html_type_chooser = AppView.type_chooser({ regiontypes: type_choices.join('') })
            @form_content = @html_type_chooser

            buttons = []
            for year in [2015..2085] by 10
                buttons.push AppView.gobutton({year: year})

            @html_form = AppView.form {formcontent: @form_content, gobuttons: buttons.join(' ') }

            @$el.append $('<div id="notreport">' + @html_form + '</div>')
            @$el.append $('<div id="report"></div>')

            @updateReportButton()

            $('body').append @$el
        # ----------------------------------------------------------------
        changeRegionType: () ->
            selected_region_type = @$('.rtype:checked').val()

            # show the good region selector dropdown
            $('#chosen_' + selected_region_type).show 'fast'

            # hide the other dropdowns
            @$('.rtype').not(':checked').each (i, elem) ->
                $('#chosen_' + $(elem).val()).hide 'fast'

            # reset the region to the selected one for this type
            @changeRegion { srcElement: $('#chosen_' + selected_region_type) }
        # ----------------------------------------------------------------
        changeRegion: (e) ->
            @selected_region = $(e.srcElement).val()
            if @selected_region == "invalid"
                @selected_region = null
            @updateReportButton()
        # ----------------------------------------------------------------
        updateReportButton: () ->
            if @selected_region
                @$('.gobutton').show 'fast'
            else
                @$('.gobutton').hide 'fast'
        # ----------------------------------------------------------------
        startReport: (e) ->

            @$('#report').empty()

            @year = $(e.srcElement).val()
            console.log ["year selected was:", @year]

            # fresh data every time
            @data = null
            @fetchData()

            # re-use the old doc if we already fetched it
            if @doc
                @progress
            else
                @fetchDoc()

            false
        # ----------------------------------------------------------------
        fetchData: () ->
            if @data
                @progress
            else
                the_region = @regions.get @selected_region
                data_url = [
                    window.settings.dataUrlPrefix
                    "regions/"
                    the_region.get 'region_type_regiontype'
                    "_"
                    the_region.get('name').replace /[^A-Za-z0-9-]/g, '_'
                    "/data.json"
                ].join ""
                $.ajax data_url, {
                    context: this
                    dataType: 'json'
                    success: (data) ->
                        @data = data
                        @progress()
                    error: () ->
                        console.log "oops didn't get data"
                }
        # ----------------------------------------------------------------
        fetchDoc: () ->
            if @doc
                @progress
            else
                doc_url = window.settings.dataUrlPrefix + "sourcedoc.txt"
                $.ajax doc_url, {
                    context: this
                    dataType: 'text'
                    success: (data) ->
                        @doc = data
                        @progress()
                    error: () ->
                        console.log "oops didn't get doc"
                }
        # ----------------------------------------------------------------
        progress: () ->
            if @doc and @data
                @generateReport()
        # ----------------------------------------------------------------
        generateReport: () ->
            # do the thing
            @data['year'] = parseInt @year
            @data['rg_url'] = 
            resolution = RA.resolve @doc, @data
            html = new Showdown.converter().makeHtml resolution

            # this appends the report into the current window
            @$('#report').append html

            # this posts the report content back to the server so it returns as a url document
            @postback html, 'report'

            # this pushes the report to the user as a download, except in IE9-
#            document.location = 'data:Application/octet-stream,' + encodeURIComponent(html);

            # this opens a new window with the report, except for popup blocking
#            report_window = window.open()
#            report_window.document.write(new Showdown.converter().makeHtml(resolution))

        # ----------------------------------------------------------------
        postback: (content, cssFiles) ->
            # content: what you want back from the server
            # cssFiles: a comma-separated list of css files, without the .css
            form = $ '<form method="post" action="/reflect"></form>'

            contentField = $ '<input type="hidden" name="content" />'
            contentField.attr 'value', content
            form.append contentField

            if cssFiles
                cssField = $ '<input type="hidden" name="css" />'
                cssField.attr 'value', cssFiles
                form.append cssField

            form.appendTo('body').submit()

        # ----------------------------------------------------------------
    },{ # ================================================================
        # templates here
        # ----------------------------------------------------------------
        form: _.template """
            <h1>Report Generator</h1>
            <form id="kickoffform">
                <%= formcontent %>
                <div class="onefield gobutton">
                    Generate report for <%= gobuttons %>
                </div>
            </form>
        """
        # ----------------------------------------------------------------
        gobutton: _.template """
            <input type="button" class="generate" value="<%= year %>" />
        """
        # ----------------------------------------------------------------
        type_chooser: _.template """
            <div class="onefield regiontypeselection">
                <%= regiontypes %>
            </div>
        """
        # ----------------------------------------------------------------
        type_choice: _.template """
                <div class="regiontypeselector">
                    <label><input type="radio" class="rtype" name="regiontyperadio"
                            value="<%= regiontype %>"><%= regiontypename_plural %></label>
                    <select class="regionselect" name="chosen_<%= regiontype %>" id="chosen_<%= regiontype %>">
                        <option disabled="disabled" selected="selected" value="invalid">choose <%= regiontypename_singular %>...</option>
                        <%= regions %>
                    </select>
                </div>
        """
        # ----------------------------------------------------------------
        region_choice: _.template """
            <option value="<%= id %>"><%= name %></option>
        """
        # ----------------------------------------------------------------
    }

    return AppView
