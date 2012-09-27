require_relative '../settings'

# --------------------------------------------------------------
class RegionType
    include DataMapper::Resource

    property :regiontype,         String, length: 16, key: true
    property :regiontypename,     String, length: 32
    property :regiontypeurl,      String, length: 255

    has n, :regions
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def self.nrm
        self.get 'NRM'
    end
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def self.ibra
        self.get 'IBRA'
    end
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def self.state
        self.get 'State'
    end
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def self.national
        self.get 'National'
    end
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end
# --------------------------------------------------------------
class Region
    include DataMapper::Resource

    property :id,                 Serial
    property :type_local_code,    String, length: 16
    property :shapefile_id,       Integer
    property :name,               String, length: 64
    property :long_name,          String, length: 64
    property :state,              String, length: 16
    property :governing_body,     String, length: 128
    property :reportable,         Boolean
    property :includes_sea,       Boolean

    belongs_to :region_type
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def data_url
        # the url for this region's data files
        Settings::DataUrlPrefix + region_type.regiontype + '_' + (name.gsub /[^A-Za-z-]+/, '_')
    end
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def to_good_json
        to_json( methods: [:data_url] )
    end
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end
# --------------------------------------------------------------
