# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# ---------------------------
# Paraná bounding box
# ---------------------------
# Geographic extent covering a portion of the city of Paraná (WGS84 lon/lat)
BBOX = [-60.556640625, -31.8402326679, -60.46875, -31.6907818061]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using satellite imagery
# Tile-based rendering is used because width/height are not specified
map = GD::GIS::Map.new(
  bbox: BBOX,
  zoom: 14,
  basemap: :esri_satellite
)

map.style = GD::GIS::Style.load("default", from: "styles")

# ---------------------------
# Load GeoJSON data
# ---------------------------
# Read a GeoJSON file containing line geometries
geo = JSON.parse(File.read("ramirez_full.geojson"))
features = geo["features"]

# ---------------------------
# Draw road surface (wide stroke)
# ---------------------------
# First pass: draw a wide semi-transparent line to represent the road surface
# Width is expressed in meters and internally projected to screen space
map.add_lines(
  features,
  stroke: [0, 0, 0, 90],   # Road outline color (RGBA)
  fill:   [0, 0, 0, 90],   # Road surface fill (RGBA)
  width:  50               # Road width in meters
)

# ---------------------------
# Draw road centerline (thin stroke)
# ---------------------------
# Second pass: draw a thinner colored line on top of the road surface
map.add_lines(
  features,
  stroke: [255, 165, 0, 90], # Highlight stroke color (RGBA)
  width:  2                  # Line width in pixels
)

# ---------------------------
# Add label
# ---------------------------
# Adds a labeled point to annotate the road
map.add_points(
  [{ lon: -60.5205, lat: -31.76, name: "Av. Ramírez" }],
  lon:   ->(p) { p[:lon] },   # Longitude accessor
  lat:   ->(p) { p[:lat] },   # Latitude accessor
  label: ->(p) { p[:name] },  # Text label
  font: "./fonts/DejaVuSans.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size: 16,                   # Label font size
  color: [0, 0, 0, 160],      # Label color (RGBA)
  icon: "mark.png"            # Marker icon image
)

# ---------------------------
# Render and save
# ---------------------------
# Render the map with all configured layers and save the output image
map.render
map.save("ramirez_gis.png")

puts "Generated ramirez_gis.png"

