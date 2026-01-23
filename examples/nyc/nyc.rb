require "gd/gis"

# ---------------------------
# New York City bounding box
# ---------------------------
# Geographic extent covering part of New York City
# (WGS84 longitude/latitude)
NYC = [-74.02, 40.70, -73.93, 40.82]

# Zoom level used for rendering (street-level detail)
ZOOM = 14

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: NYC,
  zoom: ZOOM,
  basemap: :carto_light
)

# ---------------------------
# Streets
# ---------------------------
# Load street geometries from GeoJSON.
# A custom color is provided for rendering the street network.
map.add_geojson(
  "streets.geojson",
  color: [250, 0, 0]
)

# ---------------------------
# Parks
# ---------------------------
# Load park polygon geometries from GeoJSON.
# A light green color is used to represent green areas.
map.add_geojson(
  "parks.geojson",
  color: [170, 210, 170]
)

# ---------------------------
# Boroughs
# ---------------------------
# Load borough boundary polygons from GeoJSON.
# A muted color is used to distinguish administrative areas.
map.add_geojson(
  "boroughs.geojson",
  color: [180, 180, 220]
)

# ---------------------------
# Render and save base map
# ---------------------------
# Render the map with the configured basemap and layers,
# then save the resulting image to disk.
map.render
map.save("nyc.png")

# --------------------------
# Overlay label
# --------------------------
# Open the rendered image and add a title overlay manually
# using low-level libgd drawing primitives.
img = GD::Image.open("nyc.png")

# --------------------------
# Label configuration
# --------------------------
font = "../fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path
text = "New York"

# Position and size of the label background box
x = 24
y = 24
w = 300
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
img.save("nyc.png")

