require "gd/gis"

# ---------------------------
# Paris bounding box
# ---------------------------
# Geographic extent covering the Paris metropolitan area
# (WGS84 longitude/latitude)
PARIS = [2.224, 48.815, 2.469, 48.902]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 12,
  basemap: :carto_light
)

# ---------------------------
# Load street data
# ---------------------------
# Load street geometries from a GeoJSON file.
# A custom color is provided for rendering these features.
map.add_geojson(
  "streets.geojson",
  color: [17, 55, 85]
)

# ---------------------------
# Render and save base map
# ---------------------------
# Render the map with the configured basemap and layers,
# then save the resulting image to disk.
map.render
map.save("paris.png")

# --------------------------
# Overlay label
# --------------------------
# Open the rendered image and add a title overlay manually
# using low-level libgd drawing primitives.
img = GD::Image.open("paris.png")

# --------------------------
# Label configuration
# --------------------------
font = "../fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path
text = "Paris"

# Position and size of the label background box
x = 24
y = 24
w = 240
h = 64

# --------------------------
# Background
# --------------------------
# Draw a solid background rectangle behind the label text
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
# Overwrite the original image with the labeled version
img.save("paris.png")

