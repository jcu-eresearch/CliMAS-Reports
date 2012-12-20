require './settings'

# --------------------------------------------------------------
class Species
    include DataMapper::Resource

    property :id,               Serial
    property :class,            String, :length => 32
    property :family,           String, :length => 32
    property :scientific_name,  String, :length => 128
    property :common_name,      String, :length => 64

    has n, :presence_lists
    has n, :regions, :through => :presence_lists
end
# --------------------------------------------------------------
class PresenceList
    include DataMapper::Resource

    property :occurrences,        Integer

    property :presence2015low,    String, :length => 4
    property :presence2025low,    String, :length => 4
    property :presence2035low,    String, :length => 4
    property :presence2045low,    String, :length => 4
    property :presence2055low,    String, :length => 4
    property :presence2065low,    String, :length => 4
    property :presence2075low,    String, :length => 4
    property :presence2085low,    String, :length => 4

    property :presence2015high,   String, :length => 4
    property :presence2025high,   String, :length => 4
    property :presence2035high,   String, :length => 4
    property :presence2045high,   String, :length => 4
    property :presence2055high,   String, :length => 4
    property :presence2065high,   String, :length => 4
    property :presence2075high,   String, :length => 4
    property :presence2085high,   String, :length => 4

    belongs_to :species, :key => true
    belongs_to :region,  :key => true
end
# --------------------------------------------------------------
