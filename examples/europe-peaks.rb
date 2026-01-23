# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# ---------------------------
# Europe bounding box
# ---------------------------
# Geographic extent covering most of Europe (WGS84 longitude/latitude)
EUROPE = [-15.0, 34.0, 40.0, 72.0]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: EUROPE,
  zoom: 4,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# It defines colors, stroke widths, fills, and drawing order for layers.
map.style = GD::GIS::Style.load("default", from: "styles")

# ---------------------------
# Load data
# ---------------------------
# Read JSON file containing peak locations.
# Each record is expected to include longitude, latitude, and name attributes.
peaks = JSON.parse(File.read("picks.json"))

# ---------------------------
# Add points layer
# ---------------------------
# Adds a points overlay to the map.
# Each peak is rendered using an icon and an optional text label.
map.add_points(
  peaks,
  lon: ->(p) { p["longitude"] }, # Lambda to extract longitude from each record
  lat: ->(p) { p["latitude"] },  # Lambda to extract latitude from each record
  icon: "peak.png",               # Marker icon image
  label: ->(p) { p["name"] },     # Label text displayed next to each point
  font: "./fonts/DejaVuSans.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size: 10,                       # Font size in pixels
  color: [0, 0, 0]                # Label color (RGB)
)

# ---------------------------
# Render and save
# ---------------------------
# Render the map using the configured basemap, style, and layers,
# then save the resulting image to disk.
map.render
map.save("output/europe.png")

puts "Saved output/europe.png"

