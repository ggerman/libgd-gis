require "gd/gis"

VILLAGUAY = [-59.55, -31.93, -59.43, -31.85]

map = GD::GIS::Map.new(
  bbox: VILLAGUAY,
  zoom: 13,
  basemap: :carto_light
)

map.add_geojson("rios_villaguay.geojson")

map.style = GD::GIS::Style.load("dark")

map.render
map.save("villaguay_tokyo.png")
