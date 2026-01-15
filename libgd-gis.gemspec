Gem::Specification.new do |s|
  s.name        = "libgd-gis"
  s.version     = "0.2.7"
  s.summary     = "Geospatial raster rendering for Ruby using libgd"
  s.description = "A native GIS raster engine for Ruby built on libgd. Render maps, GeoJSON, heatmaps and tiles."
  s.authors     = ["Germán Alberto Giménez Silva"]
  s.email       = ["ggerman@gmail.com"]
  s.homepage    = "https://github.com/ggerman/libgd-gis"
  s.license     = "MIT"
  s.files = Dir["lib/**/*", "README.md"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.3"
  s.add_dependency "ruby-libgd", "~> 0.2.3", ">= 0.2.3"
end
#
