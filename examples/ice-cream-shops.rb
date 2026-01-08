require "json"
require "gd/gis"

CITY = [-60.56, -31.76, -60.50, -31.71]

map = GD::GIS::Map.new(
  bbox: CITY,
  zoom: 15,
  basemap: :carto_light
)

# --------------------------------
# Cargar datos
# --------------------------------
shops = JSON.parse(File.read("heladerias.json"))

# --------------------------------
# Ice cream shops layer
# --------------------------------
map.add_points(
  shops,
  lon: ->(s) { s["lon"] },
  lat: ->(s) { s["lat"] },
  icon: "ice-cream.png",
  label: ->(s) { s["name"] },
  font: "./fonts/DejaVuSans.ttf",
  size: 11,
  color: [40,40,40]
)

# --------------------------------
# Render
# --------------------------------
map.render
map.save("output/heladerias_parana.png")

puts "Saved output/heladerias_parana.png"
