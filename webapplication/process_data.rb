
# run this to create the downloadable zip files of regional information.
# make sure settings.rb has a correct value for DataFilePrefix !

require 'json'
require './settings.rb'

region_dirs = Settings::DataFilePrefix + 'regions'

abort "Didn't find #{region_dirs}.. is your settings.rb file correct?" unless File.directory? region_dirs

Dir.foreach(region_dirs) do |dir|
	dirpath = File.join region_dirs, dir
	next unless File.directory? dirpath  # bail if this isn't a directory
	next if dir[0] == '.'[0] # don't process . and .. (or any hidden dirs)

    # ------------------------------------------------------
    # make the metadata override file

    # first find out more about our region.
    dir_parts = dir.split('_').first
    region_type = dir_parts[0]
    region_name = dir_parts[1..-1].join ' '

    # NRM regions get called "Northern Thingy Region"
    region_name += ' Region' if region_type == 'NRM'
    # IBRA regions get called "Northern Thingy Bioregion"
    region_name += ' Bioregion' if region_type == 'IBRA'
    # States just get called "Thingy" (no suffix)

    # it's a JSON serialisation, so let's just build a native object and then serialise it to JSON.
    metadata = {
        'harvester' => {
            'type' => 'directory',
            'metadata' => {
                'climas_reports' => [
                    {
                        'DATA_SUBSTITUTIONS' => {
                            'REGION_NAME' => region_name,
                            'REGION_POLY' => 'POLYGON((144.497703748 -9.91029347568,133.0719225 -9.91029347568,121.646141252 -13.182069379,110.923485004 -21.2339713912,114.790672503 -38.3639598931,132.54457875 -35.2688432623,147.837547497 -46.5179669197,158.384422495 -24.1526559825,144.497703748 -9.91029347568))',
                            'DATA_LOCATION' => "https://eresearch.jcu.edu.au/tdh/datasets/Gilbert/bifocal/regions/#{dir}/#{dir}.zip"
                    }   }
                ]
    }   }   }

    # now write the override metadata into a file..
    File.open(dirpath + '/climas-reports-specific.json', 'w') do |file|
        file.write(JSON.pretty_generate metadata)
    end

    # ------------------------------------------------------
    # make the zip file
	print "zipping in #{dirpath}.. "
	`zip -j #{dirpath}/#{dir}.zip #{dirpath}/* -x #{dirpath}/*.zip`
	puts " ..done."
    # ------------------------------------------------------

end

