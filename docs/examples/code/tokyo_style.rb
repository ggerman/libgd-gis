require "gd/gis"

TOKYO = [139.68, 35.63, 139.82, 35.75]

map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :carto_light
)

# cargar datos
map.add_geojson("water_lines.geojson")

# cargar estilo externo

map.style = GD::GIS::Style.load("dark")

# render
map.render
map.save("tokyo_water.png")
