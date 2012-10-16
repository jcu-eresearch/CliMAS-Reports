
require 'csv'
require 'pp'

line = 0
pres = {}

sqlfile = File.open "presence_lists.sql", 'w'

CSV.foreach('region-preslist.csv', {:headers => true}) do |row|

    line += 1

    preskey = "#{row['regiontype']}:#{row['regioncode']}:#{row['species']}:#{row['taxa']}"

    pres[preskey] ||= {}

    years = [ 
        row['X2015'], row['X2025'], row['X2035'], row['X2045'],
        row['X2055'], row['X2065'], row['X2075'], row['X2085']
    ]

    if row['RCP'] == "RCP45"
        pres[preskey]['low'] = years
    else
        pres[preskey]['high'] = years
    end

    # if we have both, write the sql and remove the data from the hash
    if pres[preskey]['low'] && pres[preskey]['high']

        # don't do this if everthing is 0
        if ( [].concat(pres[preskey]['low']).concat(pres[preskey]['high']).uniq == ['0'] )
            # do nothing

        else
            sql = []
            sql << "insert into presence_lists values ("
                sql << "(select id from species where class = '"
                    sql << row['taxa']
                    sql << "' and scientific_name = '"
                    sql << row['species'].gsub('_', ' ')
                sql << "'), (select id from regions where region_type_regiontype ='"
                    sql << row['regiontype']
                    sql << "' and shapefile_id = "
                    sql << row['regioncode']
                sql << "), "
                sql << pres[preskey]['low'].join(', ').gsub('3',"'kept'").gsub('2',"'gain'").gsub('1',"'lost'").gsub('0',"''")
                sql << ',  '
                sql << pres[preskey]['high'].join(', ').gsub('3',"'kept'").gsub('2',"'gain'").gsub('1',"'lost'").gsub('0',"''")
            sql << ");\n"

            sqlfile.write sql.join('')
        end

        # now clear off the data list
        pres.delete preskey

    end

    print '.' if (line % 2_500 == 0)
end

puts "done!"




        sudo /etc/init.d/httpd configtest
