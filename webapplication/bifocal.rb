
require './settings.rb'
require './data/init_data_structures.rb'
# --------------------------------------------------------------
class Bifocal < Sinatra::Base

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get '/' do
		@region_types = RegionType.all
		@regions = Region.all
		@dataurlprefix = Settings::DataUrlPrefix
		haml :frontpage
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/region/:regionid/:year/speciestables.:format" do

		region = Region.get params[:regionid]
		year = params[:year]

		
		answer = ["<h2>Biodiversity Details</h2>\n"]

=begin
		answer << "<h2>Six columns, one table</h2>\n"
		#
		#
		# six columns across, one table
		#
		#
		['mammals', 'birds', 'reptiles', 'amphibians'].each do |flavour|

			# flavour heading
			answer << "<h3>#{flavour.capitalize}</h3>"

			# start the table
			answer << "\n<table>"

			# wide header row
			answer << "<tr><th colspan='6'>"
			answer << flavour
			answer << "species with climate suitability in"
			answer << "#{region.long_name}, #{year}"
			answer << "</th></tr>"

			answer << "<tr><th colspan='3'>"
			answer << "Low emission scenario"
			answer << "</th><th colspan='3'>"
			answer << "High emission scenario"
			answer << "</th></tr>"

			# presence headers
			answer << "<tr>"
			2.times do
				['added', 'kept', 'lost'].each do |presence_title|
					answer << "<th>#{presence_title}</th>"
				end
			end
			answer << "</tr>"

			# now the data
			answer << "<tr>"
			['low', 'high'].each do |scenario|
				['gained', 'kept', 'lost'].each do |presence_type|

					presences = region.presences.all(
						year: year.to_i,
						presence: presence_type,
						scenario: scenario,
						species: [{ class: flavour }]
					)
					
					answer << "<td class='#{presence_type} specieslist' valign='top'>"

					presences.each do |presence|
						answer << "<p>"
						answer << "#{presence.species.scientific_name}"
						common_name = presence.species.common_name
						if common_name
							answer << "<br>(#{presence.species.common_name})"
						end
						answer << "</p>"
					end
					answer << "</td>"
				end
			end
			answer << "</tr>"
			answer << "</table>"
		end
=end

		['mammals', 'birds', 'reptiles', 'amphibians'].each do |flavour|

			# flavour heading
			answer << "<h3>#{flavour.capitalize}</h3>"

			# start the table
			answer << "\n<table>"

			# wide header row
			answer << "<tr><th colspan='4'>"
			answer << flavour
			answer << "with climate suitability in"
			answer << "#{region.long_name}, #{year}"
			answer << "</th></tr>"

			answer << "<tr>"
			answer << "<th rowspan='2'>current</th>"
			answer << "<th colspan='2'>Change by #{year}</th>"
			answer << "<th rowspan='2'>Species</th>"
			answer << "</tr>"

			answer << "<tr>"
			answer << "<th>high emission scenario</th>"
			answer << "<th>low emission scenario</th>"
			answer << "</tr>"

			# the data

			spp_gained_high = region.presences(
				:year => year.to_i, 
				:presence => 'gained', 
				:scenario => 'high'
			).species.all( :class => flavour )

			spp_lost_high = region.presences(
				:year => year.to_i, 
				:presence => 'lost', 
				:scenario => 'high'
			).species.all( :class => flavour )

			spp_gained_low = region.presences(
				:year => year.to_i, 
				:presence => 'gained', 
				:scenario => 'low'
			).species.all( :class => flavour )

			spp_lost_low = region.presences(
				:year => year.to_i, 
				:presence => 'lost', 
				:scenario => 'low'
			).species.all( :class => flavour )

			allspecieses = region.presences(:year => year.to_i).species.all(
				:class => flavour
			)

			allspecieses.each do |species|
				answer << "<tr><td>"
				answer << "current" unless (spp_gained_high.get(species.id) or spp_gained_low.get(species.id))
				answer << "</td><td>"
				answer << "gained" if spp_gained_low.get(species.id)
				answer << "lost" if spp_lost_low.get(species.id)
				answer << "</td><td>"
				answer << "gained" if spp_gained_high.get(species.id)
				answer << "lost" if spp_lost_high.get(species.id)
				answer << "</td><td>"
				answer << species.scientific_name
				answer << "</td></tr>"
			end

			answer << "</table>"

=begin
			answer << "<tr>"

			['low', 'high'].each do |scenario|
				['gained', 'kept', 'lost'].each do |presence_type|

					presences = region.presences.all(
						year: year.to_i,
						presence: presence_type,
						scenario: scenario,
						species: [{ class: flavour }]
					)
					
					answer << "<td class='#{presence_type} specieslist' valign='top'>"

					presences.each do |presence|
						answer << "<p>"
						answer << "#{presence.species.scientific_name}"
						common_name = presence.species.common_name
						if common_name
							answer << "<br>(#{presence.species.common_name})"
						end
						answer << "</p>"
					end
					answer << "</td>"
				end
			end
			answer << "</tr>"
			answer << "</table>"
=end

		end


		answer.join "\n"
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/regions.:format" do
		format = params[:format]
		@regions = Region.all

		if format == 'json'
			@regions.to_json
		end

		if format == 'html'
			haml :regionlist
		end

	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/regions/:regionid.:format" do
		format = params[:format]
		regionid = params[:regionid]

		if format == 'json'
			# they want a json representation of the region
			region = Region.get regionid
			if region
				# so, we have a region... return it as json
				region.to_good_json
			else
				# bail if the region wasn't found
				error 404
			end
		else
			"i don't have a #{format} format for region #{regionid}."
		end

	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# serve default data when real data not available..
	# this is for testing, remove for production
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/assets/data/sourcedoc.txt" do
		data_file_path = "public/assets/data/sourcedoc.txt"

		if File.exists? data_file_path
			File.read(data_file_path)
		else
			File.read(File.join('public', 'assets', 'data', "sourcedoc.txt"))
		end
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/assets/data/regions/:regidentifier/figure:num.png" do

		data_file_path = "public/assets/data/regions/#{params[:regidentifier]}/figure#{params[:num]}.png"

		content_type 'image/png'

		if File.exists? data_file_path
			File.read(data_file_path)
		else
			File.read(File.join('public', 'assets', 'data', "sampleFig#{params[:num]}.png"))
		end
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/assets/data/regions/:regidentifier/data.json" do

		data_file_path = 'public/assets/data/regions/#{params[:regidentifier]}/data.json'

		content_type 'application/json'

		if File.exists? data_file_path
			File.read(data_file_path)
		else
			File.read(File.join('public', 'assets', 'data', 'sampledata.json'))
		end
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	post "/reflect/?" do

		# find the filename, css files, and format they wanted
		filename = params['filename'] || 'RegionReport'
		format = params['format'] || 'html'
		css_to_include = (params['css'] && params['css'].split(',')) || []

		# set up the headers
		response['Expires'] = '0'	# don't cache
		response['Cache-Control'] = 'must-revalidate, post-check=0, pre-check=0' # really don't cache
		response['Content-Description'] = 'File Transfer' # download, don't open

		if params['format'] == 'msword-html'

			response['Content-Type'] = 'application/msword' # pretend this is a word doc
			response['Content-Disposition'] = 'attachment; filename="' + filename + '.doc"' # pretend it's a word doc

			# start the doc
			content = ['<html><head>']

			# add some MS-trickery to make Word display this properly
			# AFAICT this doesn't work, but maybe it will in older office versions
			content << "<!--[if gte mso 9]>"
	        content << "<xml>"
	        content << "<w:WordDocument>"
	        content << "<w:View>Print</w:View>"
	        content << "<w:Zoom>90</w:Zoom>"
	        content << "<w:DoNotOptimizeForBrowser/>"
	        content << "</w:WordDocument>"
	        content << "</xml>" 
	        content << "<![endif]-->"

			# add in the css files specified by the url call
			css_to_include.each do |cssfile|
				cssfile = cssfile.split('/')[0] # avoid directory trickery
				content << '<style>'
				content << File.read('public/css/' + cssfile + '.css')
				content << '</style>'
			end

	        # finish the head and start on the actual report body
			content << '</head><body><div id="report">'

			content << fix_image_sizes( prettify_table_cells(params['content']) )

			content << '</div></body></html>'

		else # default to a html report

			response['Content-Type'] = 'application/octet-stream'
			response['Content-Disposition'] = 'attachment; filename="' + filename + '.html"'

			# start the doc
			content = ['<html><head>']

			# add in the css files specified by the url call
			css_to_include.each do |cssfile|
				cssfile = cssfile.split('/')[0] # avoid directory trickery
				content << '<style>'
				content << File.read('public/css/' + cssfile + '.css')
				content << '</style>'
			end

	        # finish the head and start on the actual report body
			content << '</head><body><div id="report">'
			content << params['content']
			content << '</div></body></html>'

		end

		# return the content
		content.join "\n"

	end
	# ----------------------------------------------------------
	# convenience methods..
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	def fix_image_sizes content
		content.gsub /(<img [^>]*src="[^"]*\/)([^\.\\]+)(\.[^\."]+"[^>]+)>/ do |match|
			# $2 is the image name, less the extension. Regexes are awesome, right?

			# set the width to the fixed width from our Settings
			w = Settings::DocImageWidth

			# start the height there too, assuming a square image, but then
			# try to get the height right using the Settings::ImageSizes ratio
			h = Settings::DocImageWidth
			sizes = Settings::ImageSizes[$2.to_sym]
			h = sizes[:height] * (1.0 * w) / (1.0 * sizes[:width]) if sizes

			$1 + $2 + $3 + " width='#{w}' height='#{h}'>"
		end
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	def prettify_table_cells content

		newcontent = content

		# centre-align and add top and bottom borders to tables
		newcontent.gsub! '<table', "<table align='center' style='border-top: 1mm solid #cccccc; border-bottom: 1mm solid #cccccc; mso-cellspacing: 10px' cellpadding='5'"

		# centre-align all content in table cells
		newcontent.gsub! '<td', "<td align='center'"

		# add bottom borders to table headers
		newcontent.gsub! '<th', "<th style='border-bottom: 0.5mm solid #cccccc; border-left: 0px dotted white; border-right: 0px dotted white;'"

		# colour in the gained and lost spans
		newcontent.gsub! /<(\w+)\s+class="gained/, '<\1 style="color: #006600" class="gained'
		newcontent.gsub! /<(\w+)\s+class="lost/, '<\1 style="color: #660000" class="lost'

		# embolden any totals rows
		newcontent.gsub! '<tr class="totals', '<tr style="font-weight: bold" class="totals'

		newcontent
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# ----------------------------------------------------------
end
# --------------------------------------------------------------



























