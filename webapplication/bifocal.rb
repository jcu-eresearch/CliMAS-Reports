
require_relative './settings.rb'
require_relative './data/init_data_structures.rb'
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
	get "/region/:regionid/speciestables.:format" do
		region = Region.get params[:regionid]
		
		answer = ""

		[2015, 2035, 2055, 2075].each do |year|
			answer += "\n\n<h1>#{year}</h1><table border='1'><tr>\n"

			['add', 'lost', 'kept'].each do |presence_type|

				answer += "<td><h2>#{presence_type}</h2>\n<pre>\n"

				presences = region.presences.all year: year, presence: presence_type
				
				presences.each do |presence|
					answer += "#{presence.species.common_name}\n"
				end
				answer += "\n</pre></td>\n"
			end

			answer += "\n</tr></table>\n"
		end

		answer
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
	post "/reflect" do

		# find the file and css they wanted
		filename = params['filename'] || 'RegionReport'
		css_to_include = (params['css'] && params['css'].split(',')) || []

		# set up the headers
		response['Expires'] = '0'	# don't cache
		response['Cache-Control'] = 'must-revalidate, post-check=0, pre-check=0' # really don't cache
		response['Content-Description'] = 'File Transfer' # download, don't open
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
		newcontent = content.gsub /<table/ do |match|
			"<table align='center' style='border-top: 2px solid black; border-bottom: 2px solid black; mso-cellspacing: 10px' cellpadding='5'"
		end

		newcontent.gsub! '<td', "<td align='center'"
#		newcontent.gsub! '<th', "<th style='border-bottom: 0px solid black; border-left: 0px solid white; border-right: 0px solid white;'"
		newcontent.gsub! '<th', "<th style='border-bottom: 0px solid black; border-left: 0px dotted white; border-right: 0px dotted white;'"

		newcontent.gsub! '<span class="gained', '<span style="color: #006600" class="gained'
		newcontent.gsub! '<span class="lost', '<span style="color: #660000" class="lost'

		newcontent.gsub! '<tr class="totals', '<tr style="font-weight: bold" class="totals'

		newcontent
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# ----------------------------------------------------------
end
# --------------------------------------------------------------



























