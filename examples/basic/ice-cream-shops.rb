# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# ---------------------------
# City bounding box
# ---------------------------
# Geographic extent covering a portion of the city of Paraná (WGS84 longitude/latitude)
CITY = [-60.56, -31.76, -60.50, -31.71]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: CITY,
  zoom: 15,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# It defines visual properties such as colors, fonts, and drawing order.
map.style = GD::GIS::Style.load("default", from: "styles")

# --------------------------------
# Load data
# --------------------------------
# Read JSON file containing ice cream shop locations.
# Each record is expected to include longitude, latitude, and name fields.
shops = JSON.parse(File.read("heladerias.json"))

# --------------------------------
# Ice cream shops layer
# --------------------------------
# Adds a points overlay representing ice cream shops.
# Each shop is rendered using a custom icon and an optional label.
map.add_points(
  shops,
  lon: ->(s) { s["lon"] },        # Lambda to extract longitude
  lat: ->(s) { s["lat"] },        # Lambda to extract latitude
  icon: "ice-cream.png",          # Marker icon image
  label: ->(s) { s["name"] },     # Label text displayed next to each marker
  font: "./fonts/DejaVuSans.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size: 11,                       # Font size in pixels
  color: [40, 40, 40]             # Label color (RGB)
)

# --------------------------------
# Render
# --------------------------------
# Render the map with the configured basemap, style, and layers,
# then save the resulting image to disk.
map.render
map.save("output/heladerias_parana.png")

puts "Saved output/heladerias_parana.png"

