
require 'csv'
require 'pp'

line = 0
pres = {}

sqlfile = File.open "region_occurrences.sql", 'w'

occurfiles = Dir.new 'regional.occurrences'

occurfiles.each do |file|

	filename = 'regional.occurrences/' + file
	puts filename
	next unless File.file?(filename)
	puts filename

	regiontype = file.split('.')[0]

	line = 0
	CSV.foreach(filename, {:headers => true}) do |row|

	    line += 1
	    print '.'

	    speciesname = row['spp'].split('_').join(' ')
	    print 

	    row.headers.each do |colname|
	    	# bail if this is the spp column
	    	next if colname == 'spp'
	    	next if row[colname] == 'NA'

	    	puts "weird value: #{row[colname]}" if row[colname] != '1'

	    	shapefileid = colname.to_i

	    	sql = []
	    	sql << 'update presence_lists set occurrences = 1 where '
	    	sql << "species_id = ("
	    	sql << "select id from species where scientific_name = '#{speciesname}'"
	    	sql << ") and region_id = ("
	    	sql << "select id from region where region_type_regiontype = '#{regiontype}' and shapefile_id = #{shapefileid}"
	    	sql << ");\n"

            sqlfile.write sql.join('')
	    end
	end
end

puts "done!"




