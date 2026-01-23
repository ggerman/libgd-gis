# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "csv"
require "gd/gis"

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance covering Argentina.
# The bounding box is expressed in WGS84 longitude/latitude.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: [-73.6, -55.1, -53.6, -21.8],
  zoom: 7,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# It defines visual properties such as colors, icons, and drawing order.
map.style = GD::GIS::Style.load("default", from: "styles")

# ---------------------------
# Add locations layer
# ---------------------------
# Adds a points overlay representing populated places.
# Coordinates are extracted from the nested "centroide" object in the input data.
map.add_points(
  JSON.parse(File.read("localidades.json"))["localidades"],
  lon: ->(r) { r["centroide"]["lon"] }, # Longitude accessor
  lat: ->(r) { r["centroide"]["lat"] }, # Latitude accessor
  icon: "flag.png"                      # Marker icon image
)

# ---------------------------
# Render and save
# ---------------------------
# Render the map with the configured basemap, style, and layers,
# then save the resulting image to disk.
map.render
map.save("argentina.png")

