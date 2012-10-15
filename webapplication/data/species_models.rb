require './settings'

# --------------------------------------------------------------
class Species
    include DataMapper::Resource

    property :id,               Serial
    property :class,            String, :length => 32
    property :family,           String, :length => 32
    property :scientific_name,  String, :length => 128
    property :common_name,      String, :length => 64

    has n, :presences
    has n, :regions, :through => :presences

end
# --------------------------------------------------------------
class Presence
    include DataMapper::Resource

    property :year,             Integer, :key => true
    property :scenario,         String, :length => 4, :key => true
    property :presence,         String, :length => 4

    belongs_to :species, :key => true
    belongs_to :region,  :key => true
end
# --------------------------------------------------------------
