# --------------------------------------------------------------
require './data/connect_db'
require './data/region_models'
require './data/species_models'
# --------------------------------------------------------------
DataMapper.finalize
# --------------------------------------------------------------
DataMapper.auto_migrate!