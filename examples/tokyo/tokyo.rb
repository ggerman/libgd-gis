# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"
require "gd"

# ---------------------------
# Tokyo bounding box
# ---------------------------
# Geographic extent covering central Tokyo (WGS84 longitude/latitude)
TOKYO = [139.68, 35.63, 139.82, 35.75]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using satellite imagery.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :esri_satellite
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# This example uses a predefined "solarized" style.
map.style = GD::GIS::Style.load("solarized")

# ---------------------------
# Load GeoJSON layers
# ---------------------------
# Load railway line geometries
map.add_geojson("railways.geojson")

# Load park polygon geometries
map.add_geojson("parks.geojson")

# Load administrative ward boundaries
map.add_geojson("wards.geojson")

# ---------------------------
# Render map
# ---------------------------
# Render the map using the configured basemap, style, and layers.
# The rendered image is written to disk in the next step.
map.render
map.save("tokyo.png")

# --------------------------
# Overlay label
# --------------------------
# Open the rendered image and draw a title overlay manually
# using low-level libgd drawing primitives.
img = GD::Image.open("tokyo.png")

# --------------------------
# Label configuration
# --------------------------
font = "../fonts/DejaVuSans-Bold.ttf"
text = "TOKYO"

# Position and size of the label background box
x = 24
y = 24
w = 240
h = 64

# --------------------------
# Background
# --------------------------
# Draw a solid background rectangle for the label
img.filled_rectangle(x, y, x + w, y + h, [0, 0, 0])

# --------------------------
# Text
# --------------------------
# Draw the label text on top of the background rectangle
img.text(
  text,
  x: x + 24,
  y: y + 44,
  size: 32,
  color: [255, 255, 255],
  font: font
)

# --------------------------
# Save final image
# --------------------------
# Overwrite the original file with the labeled version
img.save("tokyo.png")

