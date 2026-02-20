Gem::Specification.new do |spec|
  spec.name        = "libgd-gis"
  spec.version     = "0.4.2"
  spec.summary     = "Geospatial raster rendering for Ruby using libgd"
  spec.description = "A native GIS raster engine for Ruby built on libgd. Render maps, GeoJSON, heatmaps and tiles."
  spec.authors     = ["Germán Alberto Giménez Silva"]
  spec.email       = ["ggerman@gmail.com"]
  spec.homepage    = "https://github.com/ggerman/libgd-gis"
  spec.license     = "MIT"
  spec.files = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.3"
  spec.add_dependency "ruby-libgd", "~> 0.2.3", ">= 0.2.3"
  spec.metadata['rubygems_mfa_required'] = 'true'
end
