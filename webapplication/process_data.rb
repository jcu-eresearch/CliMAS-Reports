
# run this to create the downloadable zip files of regional information.
# make sure settings.rb has a correct value for DataFilePrefix !

require './settings.rb'

region_dirs = Settings::DataFilePrefix + 'regions'

abort "Didn't find #{region_dirs}.. is your settings.rb file correct?" unless File.directory? region_dirs

Dir.foreach(region_dirs) do |dir|
	dirpath = File.join region_dirs, dir
	next unless File.directory? dirpath  # bail if this isn't a directory
	next if dir[0] == '.'[0] # don't process . and .. (or any hidden dirs)

	print "zipping in #{dirpath}.. "
	`zip -j #{dirpath}/#{dir}.zip #{dirpath}/* -x #{dirpath}/*.zip`
	puts " ..done."

end

