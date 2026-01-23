require "gd/gis"

TOKYO = [139.75, 35.68, 139.83, 35.74]

map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 14,
  basemap: :carto_light
)

map.add_geojson("water_lines.geojson")

map.style = GD::GIS::Style.load("dark")

map.render
map.save("tokyo_water_smaller.png")
