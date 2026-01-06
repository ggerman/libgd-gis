Gem::Specification.new do |s|
  s.name        = "libgd-gis"
  s.version     = "0.1.0"
  s.summary     = "Geospatial raster rendering for Ruby using libgd"
  s.description = "A native GIS raster engine for Ruby built on libgd. Render maps, GeoJSON, heatmaps and tiles."
  s.authors     = ["Germán Alberto Giménez Silva"]
  s.email       = ["ggerman@gmail.com"]
  s.homepage    = "https://github.com/ggerman/libgd-gis"
  s.license     = "MIT"
  s.files = Dir["lib/**/*", "README.md", "examples/**/*"]
  s.require_paths = ["lib"]
  s.add_dependency "ruby-libgd"

  s.add_dependency "ruby-libgd"
end
