# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# ---------------------------
# World bounding box
# ---------------------------
# Geographic extent used for rendering the map (WGS84 longitude/latitude)
ASIA = [25.0, -10.0, 150.0, 60.0]

# ---------------------------
# Create map
# ---------------------------
# Initializes a new GD::GIS::Map instance.
# Since width and height are not provided, the map uses tile-based rendering.
map = GD::GIS::Map.new(
  bbox: ASIA,
  zoom: 4,
  basemap: :carto_light
)


map.style = GD::GIS::Style.load("default", from: "styles")

# ---------------------------
# Load data
# ---------------------------
# Read JSON file containing peak locations.
# Each entry is expected to include longitude, latitude, and name attributes.
peaks = JSON.parse(File.read("picks.json"))

# ---------------------------
# Add points layer
# ---------------------------
# Adds a points overlay layer to the map using the provided dataset.
# Each point is rendered using an icon and an optional text label.
map.add_points(
  peaks,
  lon: ->(p) { p["longitude"] }, # Lambda to extract longitude from each record
  lat: ->(p) { p["latitude"] },  # Lambda to extract latitude from each record
  icon: "peak.png",               # Image file used as the point marker
  label: ->(p) { p["name"] },     # Label text displayed next to each point
  font: "./fonts/DejaVuSans.ttf", # Font used for labels (must be a valid .ttf file)
  size: 10,                       # Font size in pixels
  color: [0, 0, 0]                # Label color (RGB)
)

# ---------------------------
# Render and save
# ---------------------------
# Render the map using the configured basemap, layers, and style,
# then save the resulting image to disk.
map.render
map.save("output/asia.png")

puts "Saved output/asia.png"

