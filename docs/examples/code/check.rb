require "gd/gis"
features = GD::GIS::LayerGeoJSON.load("nyc_test.geojson")
puts "Features: #{features.size}"
p features.first.geometry["type"]
