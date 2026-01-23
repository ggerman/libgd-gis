require "pry"
require "gd/gis"

# ---------------------------
# Tokyo bounding box
# ---------------------------
# Geographic extent covering central Tokyo (WGS84 longitude/latitude)
TOKYO = [139.68, 35.63, 139.82, 35.75]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# Alternative predefined styles are shown below for reference.
# map.style = GD::GIS::Style::DARK
# map.style = GD::GIS::Style::SOLARIZED
map.style = GD::GIS::Style.load("solarized")

# ---------------------------
# Roads
# ---------------------------
# Load street geometries from GeoJSON.
# Multiple calls are intentionally repeated to demonstrate
# layered rendering or visual emphasis.
map.add_geojson("streets.geojson")
map.add_geojson("streets.geojson")
map.add_geojson("streets.geojson")

# ---------------------------
# Parks
# ---------------------------
# Load park polygons from GeoJSON
map.add_geojson("parks.geojson")

# ---------------------------
# Railways
# ---------------------------
# Optional railway layers (disabled in this example)
# map.add_geojson("railways.geojson")
# map.add_geojson("railways.geojson")
# map.add_geojson("railways.geojson")

# ---------------------------
# Render map
# ---------------------------
# Render the map using the configured basemap, style, and layers
map.render

# ---------------------------
# Title overlay
# ---------------------------
# Draw a semi-transparent background box and render a title label
# directly onto the resulting image.
font = "../fonts/DejaVuSans-Bold.ttf"

bg = GD::Color.rgba(0, 0, 0, 80)
fg = GD::Color.rgb(255, 255, 255)

map.image.filled_rectangle(24, 24, 264, 88, bg)

map.image.text(
  "TOKYO",
  x: 48,
  y: 68,
  size: 32,
  color: fg,
  font: font
)

# ---------------------------
# Save output
# ---------------------------
# Save the final rendered image to disk
map.save("output.png")

