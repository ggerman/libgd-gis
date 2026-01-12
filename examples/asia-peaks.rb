# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# ---------------------------
# Bounding box mundial
# ---------------------------
ASIA = [25.0, -10.0, 150.0, 60.0]

# ---------------------------
# Create map
# ---------------------------
map = GD::GIS::Map.new(
  bbox: ASIA,
  zoom: 4,
  basemap: :carto_light
)

# Cargar datos
# ---------------------------
peaks = JSON.parse(File.read("picks.json"))

# ---------------------------
# Add points layer
# ---------------------------
map.add_points(
  peaks,
  lon: ->(p) { p["longitude"] },
  lat: ->(p) { p["latitude"] },
  icon: "peak.png",
  label: ->(p) { p["name"] },
  font: "./fonts/DejaVuSans.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size: 10,
  color: [0,0,0]
)

# ---------------------------
# Render and save
# ---------------------------
map.render
map.save("output/asia.png")

puts "Saved output/asia.png"
