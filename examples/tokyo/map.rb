require "pry"
require "gd/gis"

TOKYO = [139.68, 35.63, 139.82, 35.75]

map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :carto_light
)

# map.style = GD::GIS::Style::DARK
# map.style = GD::GIS::Style::SOLARIZED
map.style = GD::GIS::Style.load("solarized")

# Roads
map.add_geojson("streets.geojson")
map.add_geojson("streets.geojson")
map.add_geojson("streets.geojson")

map.add_geojson("parks.geojson")

# Railways
# map.add_geojson("railways.geojson")
# map.add_geojson("railways.geojson")
# map.add_geojson("railways.geojson")

map.render

font = "../fonts/DejaVuSans-Bold.ttf"

bg = GD::Color.rgba(0, 0, 0, 80)
fg = GD::Color.rgb(255, 255, 255)

map.image.filled_rectangle(24, 24, 264, 88, bg)

map.image.text(
  "TOKYO",
  x: 48,
  y: 68,
  size: 32,
  color: fg,
  font: font
)

map.save("1.png")

