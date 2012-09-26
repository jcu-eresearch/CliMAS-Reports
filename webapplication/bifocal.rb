
require_relative './settings.rb'
require_relative './data/init_data_structures.rb'
# --------------------------------------------------------------
class Bifocal < Sinatra::Base

	if Settings::Dev == 'true'
		register Sinatra::Reloader
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get '/' do
		send_file File.join(settings.public_folder, 'index.html')
	end
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	get "/regions.:format" do
		format = params[:format]

		if format == 'json'
			Region.all.to_json
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

	# ----------------------------------------------------------
end
# --------------------------------------------------------------
