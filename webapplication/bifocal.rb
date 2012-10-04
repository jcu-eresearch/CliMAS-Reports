
require_relative './settings.rb'
require_relative './data/init_data_structures.rb'
# --------------------------------------------------------------
class Bifocal < Sinatra::Base

	if Settings::Dev == 'true'
		register Sinatra::Reloader
	end
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

	# ----------------------------------------------------------
end
# --------------------------------------------------------------
