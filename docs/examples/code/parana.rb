require "gd/gis"

PARANA = [-60.57, -31.81, -60.45, -31.69]

map = GD::GIS::Map.new(
  bbox: PARANA,
  zoom: 12,
  basemap: :carto_light
)

map.add_geojson("rios_parana.geojson")

map.style = GD::GIS::Style.load("dark")

map.render
map.save("parana_water.png")
