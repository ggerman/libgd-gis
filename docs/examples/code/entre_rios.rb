require "gd/gis"

ER = [-60.95, -33.85, -57.75, -30.15]

map = GD::GIS::Map.new(
  bbox: ER,
  zoom: 6,
  basemap: :carto_light
)

map.add_geojson("rios_entre_rios_tokyo.geojson")

map.style = GD::GIS::Style.load("dark")

map.render
map.save("debug.png")
