define [
    'jquery', 'underscore', 'backbone', 'showdown',
    'bifocal/collections/regions'
    'bifocal/collections/regiontypes'
    'ra'
], ($, _, Backbone, Showdown, Regions, RegionTypes, RA) ->

    AppView = Backbone.View.extend {
        # ----------------------------------------------------------------
        events:
            'change input[type=radio].rtype':  'changeRegionType'
            'change select.regionselect':      'changeRegion'
            'change input[type=radio].year':   'changeYear'
            'change input[type=radio].format': 'changeFormat'
            'click .generate':                 'startReport'
        # ----------------------------------------------------------------
        initialize: () ->
            # window.region_list initialised in the HAML template
            @region_types = new RegionTypes window.region_type_list
            @regions = new Regions window.region_list
            _.bindAll this
        # ----------------------------------------------------------------
        render: () ->

            me = this

            form_parts = []

            # regiontype and region -----

            type_choices = []
            @region_types.each (rt) ->

                # make a list of that region type's regions
                region_list = []
                me.regions.each (r) ->
                    if r.get('region_type_regiontype') == rt.get('regiontype')
                        region_list.push AppView.region_option(r.attributes)

                # merge the region list into the region type attributes
                info = _.extend({regions: region_list.join('')}, rt.attributes)
                type_choices.push AppView.type_choice(info)

            form_parts.push AppView.type_chooser({ regiontypes: type_choices.join('') })

            # year -----

            years = []
            for year in [2015..2085] by 10
                years.push AppView.year_option { year: year }

            form_parts.push AppView.year_chooser { years: years.join('\n') }

            # format -----

            formats = []
            for f, n of {
                'msword-html': 'MS Word-compatible HTML document'
                'html'       : 'Clean HTML document'
                'preview'    : 'Preview in this browser window'
            }
                formats.push AppView.format_option { format: f, formatname: n }

            form_parts.push AppView.format_chooser { formats: formats.join('') }

            # final form -----

            html_form = AppView.form { formcontent: form_parts.join('') }

            @$el.append $('<div id="notreport">' + html_form + '</div>')

            @updateReportButton()

            $('.maincontent').append @$el
        # ----------------------------------------------------------------
        regionDataUrl: (region) ->
            # did we get a region id or actual model?

            # if it's a model, great
            the_region = region

            if typeof(region) == 'string'
                # if it's a region id, fetch the model
                the_region = @regions.get region

            url = [
                window.settings.dataUrlPrefix
                "regions/"
                the_region.get 'region_type_regiontype'
                "_"
                the_region.get('name').replace /[^A-Za-z0-9-]/g, '_'
                "/"
            ].join ""

            url
        # ----------------------------------------------------------------
        changeRegionType: () ->
            selected_region_type = @$('.rtype:checked').val()

            # show the good region selector dropdown
#            $('#chosen_' + selected_region_type).show 'fast'
            $('#chosen_' + selected_region_type).css "visibility", "visible"

            # hide the other dropdowns
            @$('.rtype').not(':checked').each (i, elem) ->
#                $('#chosen_' + $(elem).val()).hide 'fast'
                $('#chosen_' + $(elem).val()).css "visibility", "hidden"

            # reset the region to the selected one for this type
            @changeRegion { srcElement: $('#chosen_' + selected_region_type) }
        # ----------------------------------------------------------------
        changeRegion: (e) ->
            @selected_region = $(e.srcElement).val()
            if @selected_region == "invalid"
                @selected_region = null
            @updateReportButton()
        # ----------------------------------------------------------------
        changeYear: (e) ->
            @year = $(e.srcElement).val()
            @updateReportButton()
        # ----------------------------------------------------------------
        changeFormat: (e) ->
            @format = $(e.srcElement).val()
            @updateReportButton()
        # ----------------------------------------------------------------
        updateReportButton: () ->
            if @selected_region and @year and @format
                @$('.generate').removeAttr 'disabled'
            else
                @$('.generate').attr 'disabled', 'disabled'
        # ----------------------------------------------------------------
        startReport: (e) ->

            @$('#report').empty()

            document.body.style.cursor = 'wait'

            @updateProgress()

            # fresh data every time
            @data = null

            # fresh appendix every time
            @appendix = null

            # re-use the old doc if we already fetched it
            @fetchDoc() unless @doc
            @fetchData()
            @fetchAppendix()

            @updateProgress()

            false
        # ----------------------------------------------------------------
        updateProgress: () ->
            fetchlist = {
                'template': @doc
                'data': @data
                'tables': @appendix
            }
            progress = ''
            done = true
            for name, item of fetchlist
                if item
                    progress += '&#10003;'
                else
                    progress += '&#8987;'
                    done = false
                progress += name
                progress += ' '
            $button = @$('.generate')
            if done
                $button.removeAttr 'disabled'
                $button.css 'cursor', 'pointer'
            else
                $button.attr 'disabled', 'disabled'
                $button.css 'cursor', 'wait'
            @$('.generate').html progress
        # ----------------------------------------------------------------
        fetchData: () ->
            if @data
                @progress
            else
                data_url = @regionDataUrl(@selected_region) + "data.json"
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
        fetchAppendix: () ->
            if @appendix
                @progress
            else
#                @appendix = "<p>(appendix will go here)</p>"

                appendix_url = window.settings.siteUrlPrefix + "region/#{@selected_region}/#{@year}/speciestables.html"
                $.ajax appendix_url, {
                    context: this
                    dataType: 'html'
                    success: (data) ->
                        @appendix = data
                        @progress()
                    error: () ->
                        console.log "oops didn't get appendix"
                }
        # ----------------------------------------------------------------
        progress: () ->
            @updateProgress()
            if @doc and @data and @appendix
                @generateReport()
        # ----------------------------------------------------------------
        generateReport: () ->
            # do the thing
            @data['year'] = @year

            the_region = @regions.get @selected_region

            @data['rg_url'] = @regionDataUrl the_region
            @data['rg_short_name'] = the_region.get 'name'
            @data['rg_long_name'] = the_region.get 'long_name'

            console.log @data

            resolution = RA.resolve @doc, @data
            html = new Showdown.converter().makeHtml resolution

            html += @appendix

            if @format == 'preview'
                # this appends the report into the current window
                $('body').append $('<div id="report"></div>')
                $('#report').append html
                $('#report').scrollIntoView true


            else
                # this posts the report content back to the server so it returns as a url document
                @postback html, 'report', @format

            document.body.style.cursor = 'default'

            # this would push the report to the user as an html download, except in IE 6,7,8,9
            # document.location = 'data:Application/octet-stream,' + encodeURIComponent(html);

            # this opens a new window with the report, except for popup blocking
            # report_window = window.open()
            # report_window.document.write(new Showdown.converter().makeHtml(resolution))

        # ----------------------------------------------------------------
        postback: (content, cssFiles, format) ->
            # content: what you want back from the server
            # cssFiles: a comma-separated list of css files, without the .css
            # format: the format you want back, e.g. 'msword_html' or 'html'

            form = $ '<form method="post" action="' + window.settings.siteUrlPrefix + 'reflect"></form>'

            formatField = $ '<input type="hidden" name="format" />'
            formatField.attr 'value', format
            form.append formatField

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
            <form id="kickoffform" class="clearfix">
                <%= formcontent %>
            </form>
        """
        # ----------------------------------------------------------------
        # ----------------------------------------------------------------
        format_option: _.template """
            <label><input type="radio" class="format" name="formatradio" value="<%= format %>">
                <%= formatname %>
            </label>
        """
        # ----------------------------------------------------------------
        format_chooser: _.template """
            <div class="onefield formatselection formsection">
                <h3>Select an output format</h3>
                <%= formats %>
                <button class="generate" disabled="disabled">generate report</button>
            </div>
        """
        # ----------------------------------------------------------------
        # ----------------------------------------------------------------
        year_option: _.template """
            <label><input type="radio" class="year" name="yearradio" value="<%= year %>">
                <%= year %>
            </label>
        """
        # ----------------------------------------------------------------
        year_chooser: _.template """
            <div class="onefield yearselection formsection">
                <h3>Select a year</h3>
                <%= years %>
            </div>
        """
        # ----------------------------------------------------------------
        # ----------------------------------------------------------------
        type_choice: _.template """
                <div class="regiontypeselector">
                    <label><input type="radio" class="rtype" name="regiontyperadio"
                            value="<%= regiontype %>"><%= regiontypename_plural %></label>
                    <select class="regionselect" name="chosen_<%= regiontype %>" id="chosen_<%= regiontype %>">
                        <option disabled="disabled" selected="selected" value="invalid">choose a region...</option>
                        <%= regions %>
                    </select>
                </div>
        """
        # ----------------------------------------------------------------
        region_option: _.template """
            <option value="<%= id %>"><%= name %></option>
        """
        # ----------------------------------------------------------------
        type_chooser: _.template """
            <div class="onefield regiontypeselection formsection">
                <h3>Select a region</h3>
                <%= regiontypes %>
            </div>
        """
        # ----------------------------------------------------------------
    }

    return AppView
