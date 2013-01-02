// Generated by CoffeeScript 1.4.0
(function() {

  define(['jquery', 'underscore', 'backbone', 'showdown', 'bifocal/collections/regions', 'bifocal/collections/regiontypes', 'ra'], function($, _, Backbone, Showdown, Regions, RegionTypes, RA) {
    var AppView;
    AppView = Backbone.View.extend({
      events: {
        'change input[type=radio].rtype': 'changeRegionType',
        'change select.regionselect': 'changeRegion',
        'change input[type=radio].year': 'changeYear',
        'change input[type=radio].format': 'changeFormat',
        'click .generate': 'startReport'
      },
      initialize: function() {
        this.region_types = new RegionTypes(window.region_type_list);
        this.regions = new Regions(window.region_list);
        return _.bindAll(this);
      },
      render: function() {
        var f, form_parts, formats, html_form, me, n, type_choices, year, years, _i, _ref;
        me = this;
        form_parts = [];
        type_choices = [];
        this.region_types.each(function(rt) {
          var info, region_list;
          if (rt.get('regiontype') !== 'National') {
            region_list = [];
            me.regions.each(function(r) {
              if (r.get('region_type_regiontype') === rt.get('regiontype')) {
                return region_list.push(AppView.region_option(r.attributes));
              }
            });
            info = _.extend({
              regions: region_list.join('')
            }, rt.attributes);
            return type_choices.push(AppView.type_choice(info));
          }
        });
        form_parts.push(AppView.type_chooser({
          regiontypes: type_choices.join('')
        }));
        years = [];
        for (year = _i = 2015; _i <= 2085; year = _i += 10) {
          years.push(AppView.year_option({
            year: year
          }));
        }
        form_parts.push(AppView.year_chooser({
          years: years.join('\n')
        }));
        formats = [];
        _ref = {
          'html': 'Download a HTML document',
          'preview': 'Preview in this browser window'
        };
        for (f in _ref) {
          n = _ref[f];
          formats.push(AppView.format_option({
            format: f,
            formatname: n
          }));
        }
        form_parts.push(AppView.format_chooser({
          formats: formats.join('')
        }));
        html_form = AppView.form({
          formcontent: form_parts.join('')
        });
        this.$el.append($('<div id="notreport">' + html_form + '</div>'));
        this.updateReportButton();
        return $('.maincontent').append(this.$el);
      },
      regionDataUrl: function(region) {
        var the_region, url;
        the_region = region;
        if (typeof region === 'string') {
          the_region = this.regions.get(region);
        }
        url = [window.settings.dataUrlPrefix, "regions/", the_region.get('region_type_regiontype'), "_", the_region.get('name').replace(/[^A-Za-z0-9-]/g, '_'), "/"].join("");
        return url;
      },
      changeRegionType: function() {
        var selected_region_type;
        selected_region_type = this.$('.rtype:checked').val();
        $('#chosen_' + selected_region_type).css("visibility", "visible");
        this.$('.rtype').not(':checked').each(function(i, elem) {
          return $('#chosen_' + $(elem).val()).css("visibility", "hidden");
        });
        return this.changeRegion({
          target: $('#chosen_' + selected_region_type)
        });
      },
      changeRegion: function(e) {
        this.selected_region = $(e.target).val();
        if (this.selected_region === "invalid") {
          this.selected_region = null;
        }
        if (this.selected_region) {
          console.log('showing region dl');
          this.$('#regiondownloadlink').prop('href', this.regionDataUrl(this.selected_region));
          this.$('#regiondownloadlink').css("visibility", "visible");
        } else {
          this.$('#regiondownloadlink').css("visibility", "hidden");
        }
        return this.updateReportButton();
      },
      changeYear: function(e) {
        this.year = $(e.target).val();
        return this.updateReportButton();
      },
      changeFormat: function(e) {
        this.format = $(e.target).val();
        return this.updateReportButton();
      },
      updateReportButton: function() {
        if (this.selected_region && this.year && this.format) {
          return this.$('.generate').removeAttr('disabled');
        } else {
          return this.$('.generate').attr('disabled', 'disabled');
        }
      },
      startReport: function(e) {
        this.$('#report').empty();
        this.enterLoadingState();
        this.updateProgress();
        this.doc = null;
        this.data = null;
        this.appendix = null;
        this.fetchDoc();
        this.fetchData();
        this.fetchAppendix();
        this.updateProgress();
        return e.preventDefault();
      },
      updateProgress: function() {
        var $button, done, fetchlist, item, name, progress;
        fetchlist = {
          'template': this.doc,
          'data': this.data,
          'tables': this.appendix
        };
        progress = '';
        done = true;
        for (name in fetchlist) {
          item = fetchlist[name];
          if (item) {
            progress += '&#10003;';
          } else {
            progress += '&#8987;';
            done = false;
          }
          progress += name;
          progress += ' ';
        }
        $button = this.$('.generate');
        if (done) {
          return this.exitLoadingState();
        } else if (this.loading) {
          return this.$('.generate').html(progress);
        }
      },
      fetchData: function() {
        var data_url,
          _this = this;
        if (this.data) {
          return this.progress;
        } else {
          data_url = this.regionDataUrl(this.selected_region) + "data.json";
          return $.ajax(data_url, {
            context: this,
            dataType: 'json',
            success: function(data) {
              _this.data = data;
              return _this.progress();
            },
            error: function() {
              _this.exitLoadingState();
              return alert("Could not fetch data for this region.\n\nDue to modelling constraints, we can only report on continental Australia.\n\nLet us know if you think we're missing data for your region.");
            }
          });
        }
      },
      fetchDoc: function() {
        var doc_url,
          _this = this;
        if (this.doc) {
          return this.progress;
        } else {
          doc_url = window.settings.dataUrlPrefix + "sourcedoc.txt";
          return $.ajax(doc_url, {
            context: this,
            dataType: 'text',
            success: function(data) {
              _this.doc = data;
              return _this.progress();
            },
            error: function() {
              _this.exitLoadingState();
              return alert("Could not fetch the report template.\n\nThis should only happen if your network is down; if you're sure your connection is okay, we'd appreciate it if you reported this problem to the developers.");
            }
          });
        }
      },
      fetchAppendix: function() {
        var appendix_url,
          _this = this;
        if (this.appendix) {
          return this.progress;
        } else {
          appendix_url = window.settings.siteUrlPrefix + ("region/" + this.selected_region + "/" + this.year + "/speciestables.html");
          return $.ajax(appendix_url, {
            context: this,
            dataType: 'html',
            success: function(data) {
              _this.appendix = data;
              return _this.progress();
            },
            error: function() {
              _this.exitLoadingState();
              return alert("Could not fetch data for this region.\n\nDue to modelling constraints, we can only report on continental Australia.\n\nLet us know if you think we're missing data for your region.");
            }
          });
        }
      },
      enterLoadingState: function() {
        this.loading = true;
        document.body.style.cursor = 'wait';
        this.$('.generate').attr('disabled', 'disabled');
        return this.$('.generate').css('cursor', 'wait');
      },
      exitLoadingState: function() {
        this.loading = false;
        document.body.style.cursor = 'default';
        this.$('.generate').removeAttr('disabled').css('cursor', 'pointer');
        return this.$('.generate').html('generate report');
      },
      progress: function() {
        this.updateProgress();
        if (this.doc && this.data && this.appendix) {
          return this.generateReport();
        }
      },
      generateReport: function() {
        var html, resolution, the_region;
        this.data['year'] = this.year;
        the_region = this.regions.get(this.selected_region);
        this.data['rg_url'] = this.regionDataUrl(the_region);
        this.data['rg_short_name'] = the_region.get('name');
        this.data['rg_long_name'] = the_region.get('long_name');
        resolution = RA.resolve(this.doc, this.data);
        html = new Showdown.converter().makeHtml(resolution);
        html += this.appendix;
        if (this.format === 'preview') {
          $('body').append($('<div id="report"></div>'));
          $('#report').html(html);
          $('#report').get(0).scrollIntoView(true);
        } else {
          this.postback(html, 'report', this.format);
        }
        return document.body.style.cursor = 'default';
      },
      postback: function(content, cssFiles, format) {
        var contentField, cssField, form, formatField;
        form = $('<form method="post" action="' + window.settings.siteUrlPrefix + 'reflect"></form>');
        formatField = $('<input type="hidden" name="format" />');
        formatField.attr('value', format);
        form.append(formatField);
        contentField = $('<input type="hidden" name="content" />');
        contentField.attr('value', content);
        form.append(contentField);
        if (cssFiles) {
          cssField = $('<input type="hidden" name="css" />');
          cssField.attr('value', cssFiles);
          form.append(cssField);
        }
        return form.appendTo('body').submit();
      }
    }, {
      form: _.template("<p class=\"toolintro\">\n    Get a regional report on projected changes in temperature,\n    rainfall, and species composition for a selected year.\n    <br>Species included are land-based Australian birds, mammals,\n    reptiles and amphibians.\n</p>\n<form id=\"kickoffform\" class=\"clearfix\">\n    <%= formcontent %>\n</form>"),
      format_option: _.template("<label><input type=\"radio\" class=\"format\" name=\"formatradio\" value=\"<%= format %>\">\n    <%= formatname %>\n</label>"),
      format_chooser: _.template("<div class=\"onefield formatselection formsection\">\n    <h3>Select an output format</h3>\n    <%= formats %>\n    <button class=\"generate\">generate report</button>\n</div>"),
      year_option: _.template("<label><input type=\"radio\" class=\"year\" name=\"yearradio\" value=\"<%= year %>\">\n    <%= year %>\n</label>"),
      year_chooser: _.template("<div class=\"onefield yearselection formsection\">\n    <h3>Select a year</h3>\n    <%= years %>\n</div>"),
      type_choice: _.template("<div class=\"regiontypeselector\">\n    <label><input type=\"radio\" class=\"rtype\" name=\"regiontyperadio\"\n            value=\"<%= regiontype %>\"><%= regiontypename_plural %></label>\n    <select class=\"regionselect\" name=\"chosen_<%= regiontype %>\" id=\"chosen_<%= regiontype %>\">\n        <option disabled=\"disabled\" selected=\"selected\" value=\"invalid\">choose a region...</option>\n        <%= regions %>\n    </select>\n</div>"),
      region_option: _.template("<option value=\"<%= id %>\"><%= name %></option>"),
      type_chooser: _.template("<div class=\"onefield regiontypeselection formsection\">\n    <h3>Select a region</h3>\n    <%= regiontypes %>\n    <a id=\"regiondownloadlink\" href=\"\">download region data</a>\n</div>")
    });
    return AppView;
  });

}).call(this);
