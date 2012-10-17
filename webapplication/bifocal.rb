
require './settings.rb'
require './data/init_data_structures.rb'

require 'pp'
# --------------------------------------------------------------
class Bifocal < Sinatra::Base
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get '/' do
		@region_types = RegionType.all
		@regions = Region.all
		@dataurlprefix = Settings::DataUrlPrefix
		@siteurlprefix = Settings::SiteUrlPrefix
		haml :frontpage
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/region/:regionid/:year/speciestables.:format" do

		region = Region.get params[:regionid]
		year = params[:year]
		
		answer = ["<h2>Biodiversity Details</h2>\n"]

		['mammals', 'birds', 'reptiles', 'amphibians'].each do |flavour|

			# flavour heading
			answer << "<h3>#{flavour.capitalize}</h3>"

			# start the table
			answer << "\n<table class='specieslist'>"

			answer << "<thead>"

			# wide header row
			answer << "<tr>"

			answer << "<th colspan='7'>"
			answer << flavour
			answer << "with climate suitability in"
			answer << "#{region.long_name}, #{year}"
			answer << "</th></tr>"


			answer << "<tr>"

			answer << "<th colspan='2'>emission scenario</th>"
			answer << "<th rowspan='2'>Species</th>"

			answer << "<td rowspan='2'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>"

			answer << "<th colspan='2'>emission scenario</th>"
			answer << "<th rowspan='2'>Species</th>"

			answer << "</tr>"


			answer << "<tr>"
			answer << "<th>high</th>"
			answer << "<th>low</th>"

			answer << "<th>high</th>"
			answer << "<th>low</th>"
			answer << "</tr>"

			answer << "</thead><tbody>"

			# the data

			allpresences = region.presence_lists.all(
				:species => { :class => flavour }
			)

			index = 0

			allpresences.each do |presence|

				low = presence.send :"presence#{year}low"
				high = presence.send :"presence#{year}high"

				next if low == '' and high == ''

				answer << "<tr>" if index % 2 == 0

				low = 'gained' if low == 'gain'
				low = '&ndash;' if low == ''

				high = 'gained' if high == 'gain'
				high = '&ndash;' if high == ''

				answer << "<td style='text-align: center' class='#{high}'>#{high}</td>"
				answer << "<td style='text-align: center' class='#{low}'>#{low}</td>"

				answer << "</td><td>"
				answer << presence.species.scientific_name
				answer << "</td>"

				answer << "<td></td>" if index % 2 == 0
				answer << "</tr>" if index % 2 == 1

				index += 1
			end

			answer << "</tbody>"
			answer << "</table>"

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
	get "/assets/data/sourcedoc.txt" do
		data_file_path = Settings::DataFilePrefix + "sourcedoc.txt"

		if File.exists? data_file_path
			File.read(data_file_path)
		else
			error 404
		end
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/assets/data/regions/:regidentifier/:figure.png" do

		data_file_path = Settings::DataFilePrefix + "regions/#{params[:regidentifier]}/#{params[:figure]}.png"

		content_type 'image/png'

		if File.exists? data_file_path
			File.read(data_file_path)
		else
			error 404
		end
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/assets/data/regions/:regidentifier/data.json" do

		data_file_path = Settings::DataFilePrefix + "regions/#{params[:regidentifier]}/data.json"

		content_type 'application/json'

		if File.exists? data_file_path
			File.read(data_file_path)
		else
			error 404
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

		# reserve specieslist tables for now..
		newcontent.gsub! "<table class='specieslist'", "<spptable class='specieslist'"

		# centre-align and add top and bottom borders to tables
		newcontent.gsub! '<table', "<table align='center' style='border-top: 1mm solid #cccccc; border-bottom: 1mm solid #cccccc; mso-cellspacing: 10px' cellpadding='5'"

		# find those specieslist tables and do the same, but with less padding
		newcontent.gsub! '<spptable', "<table align='center' style='border-top: 1mm solid #cccccc; border-bottom: 1mm solid #cccccc; mso-cellspacing: 3px' cellpadding='2'"

		# centre-align all content in table cells
		newcontent.gsub! '<td', "<td align='center'"

		# add bottom borders to table headers
		newcontent.gsub! /<th(\s|>)/, "<th style='border-bottom: 0.5mm solid #cccccc; border-left: 0px dotted white; border-right: 0px dotted white;' \\1"
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



























