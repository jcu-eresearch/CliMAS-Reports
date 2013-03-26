
# run this to create the downloadable zip files of regional information.
# make sure settings.rb has a correct value for DataFilePrefix !

require 'json'
require './settings.rb'
require './data/init_data_structures.rb'

region_dirs = Settings::DataFilePrefix + 'regions'

abort "Didn't find #{region_dirs}.. is your settings.rb file correct?" unless File.directory? region_dirs

Dir.foreach(region_dirs) do |dir|

	dirpath = File.join region_dirs, dir
	next unless File.directory? dirpath  # bail if this isn't a directory
	next if dir[0] == '.'[0] # don't process . and .. (or any hidden dirs)

    # ------------------------------------------------------
    # gather data together for the metadata override file

    # first find out more about our region.
    dir_parts = dir.split('_')
    region_type = dir_parts[0]

    region_name = dir_parts[1..-1].join ' '

    # fancy-up a pretty version of the name for humans to read:

    region_nice_name = region_name

    # NRM regions get called "Northern Thingy Region"
    region_nice_name += ' NRM Region' if region_type == 'NRM'
    # IBRA regions get called "Northern Thingy Bioregion"
    region_nice_name += ' IBRA Bioregion' if region_type == 'IBRA'
    # States just get called "Thingy" (no suffix)

    # put the fancy name into a phrase for use in textual descriptions:

    region_name_phrase = region_nice_name

    if region_type == 'NRM'
        # NRM Regions get called 'the Australian NRM region of ...'
        region_name_phrase = 'the Australian NRM region of ' + region_name

    elsif region_type == 'IBRA'
        # IBRA Regions get called 'the Australian IBRA bioregion of ...'
        region_name_phrase = 'the Australian IBRA bioregion of ' + region_name

    elsif region_type == 'State' and region_name =~ /^Australian/
        # Territories starting with 'Australian' get called 'the [Australian]...'
        region_name_phrase = 'the ' + region_name

    elsif region_type == 'State' and region_name =~ /Territory$/
        # Other territories get called 'the ...[Territory] of Australia'
        region_name_phrase = 'the ' + region_name + ' of Australia'

    elsif region_type == 'State'
        # States get called 'the Australian state of ...'
        region_name_phrase = 'the Australian state of ' + region_name

    end

    # we need the region's simplified polygon out of the database:

    region_poly = Region.first(:name => region_name).simplified_polygon

    # ------------------------------------------------------
    # now we've assembled all the data we need. The metadata
    # override file is a JSON serialisation, so let's just
    # build a native object and then serialise it to JSON.
    metadata = {
        'harvester' => {
            'type' => 'directory',
            'metadata' => {
                'climas_reports' => [
                    {
                        'DATA_SUBSTITUTIONS' => {
                            'REGION_NAME' => region_nice_name,
                            'REGION_PHRASE' => region_name_phrase,
                            'REGION_POLY' => region_poly,
                            'DATA_LOCATION' => "https://eresearch.jcu.edu.au/tdh/datasets/Gilbert/bifocal/regions/#{dir}/#{dir}.zip"
                    }   }
                ]
    }   }   }

    # now write the override metadata into a file..
    File.open(dirpath + '/climas-reports-metadata-override.json', 'w') do |file|
        file.write(JSON.pretty_generate metadata)
    end

    # ------------------------------------------------------
    # make the zip file
	print "zipping in #{dirpath}.. "
	`zip -j #{dirpath}/#{dir}.zip #{dirpath}/* -x #{dirpath}/*.zip`
	puts " ..done."
    # ------------------------------------------------------

end

