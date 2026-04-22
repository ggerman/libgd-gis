require "gd/gis"
require_relative "fonts"

OUTPUT = "output/payunia.png"
GEOJSON = "data/volcanoes.geojson"

bbox = GD::GIS::Geometry.bbox_for_image(
  GEOJSON,
  :zoom => 13,
  :width => 800,
  :height => 600,
  :padding_px => 100
)

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 9,
  :width => 800,
  :height => 600,
  basemap: :esri_terrain
)

map.style = GD::GIS::Style.load("solarized")

map.add_geojson(GEOJSON)

map.render
map.save(OUTPUT)
puts "✔ Generated: #{OUTPUT}"

