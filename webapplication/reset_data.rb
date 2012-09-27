# --------------------------------------------------------------
# connect to the database
require_relative './data/connect_db'

# tell datamapper about the tables
require_relative './data/region_models'

# create tables
DataMapper.finalize
DataMapper.auto_upgrade!

# --------------------------------------------------------------
# populate the regiontypes
RegionType.first_or_new({regiontype: "NRM"},      {regiontypeurl: "http://www.nrm.gov.au/about/nrm/regions/"}).save
RegionType.first_or_new({regiontype: "IBRA"},     {regiontypeurl: "http://www.environment.gov.au/parks/nrs/science/bioregion-framework/ibra/"}).save
RegionType.first_or_new({regiontype: "State"},    {regiontypeurl: "http://www.gov.au/"}).save
RegionType.first_or_new({regiontype: "National"}, {regiontypeurl: "http://australia.gov.au/"}).save

# --------------------------------------------------------------
# populate the regions
r = Region.new(
    region_type: RegionType::nrm,
    type_local_code: 'FAK',
    shapefile_id: 1,
    name: 'Fake Demo',
    long_name: 'Fake Demo Region',
    state: 'West Queensmania',
    governing_body: 'Cloud City',
    reportable: true,
    includes_sea: true,
)
if r.save
    puts "save okay!"
else
    puts "save failed:"
    r.errors.each do |e|
       puts "  " + e.to_s
    end
end
