# --------------------------------------------------------------
require_relative './connect_db'
require_relative './region_models'
require_relative './species_models'
# --------------------------------------------------------------
DataMapper.finalize
# --------------------------------------------------------------
DataMapper.auto_migrate!