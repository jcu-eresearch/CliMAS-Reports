
# run this to create the downloadable zip files of regional information.
# make sure settings.rb has a correct value for DataFilePrefix !

require './settings.rb'

region_dirs = Dir.new(Settings::DataFilePrefix + 'regions')

abort "Didn't find #{region_dirs}.. is your settings.rb file correct?" unless File.directory? region_dirs.to_s

region_dirs.entries.each do |dir|
	dirpath = File.join region_dirs.to_s, dir.to_s
	puts dirpath
	next unless File.directory? dirpath  # bail of this isn't a dir
	next if dir[0] == '.' # don't process . and .. (or any hidden dirs)

	# okay now the dirpath is a real regional directory

	`zip #{dirpath}/#{dir}.zip #{dirpath}/* -x #{dirpath}/*.zip`

end

