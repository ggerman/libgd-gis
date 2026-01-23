require "gd/gis"

# ---------------------------
# Paris bounding box
# ---------------------------
# Geographic extent covering central Paris (WGS84 longitude/latitude)
PARIS = [2.25, 48.80, 2.42, 48.90]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# This example uses a predefined "solarized" style.
map.style = GD::GIS::Style.load("solarized")

# ---------------------------
# Seine river
# ---------------------------
# Load river line geometries from GeoJSON.
# These features are typically rendered as water layers by the style.
map.add_geojson("data/seine.geojson")

# ---------------------------
# Parks
# ---------------------------
# Load park polygon geometries from GeoJSON.
map.add_geojson("data/parks.geojson")

# ---------------------------
# Points of interest
# ---------------------------
# Define a list of points of interest to be rendered as markers.
pois = [
  { "name" => "Eiffel Tower", "lon" => 2.2945, "lat" => 48.8584 }
]

# ---------------------------
# Add points layer
# ---------------------------
# Adds a points overlay representing points of interest.
# Each point is rendered using a custom icon and an optional label.
map.add_points(
  pois,
  lon:   ->(r) { r["lon"].to_f },  # Longitude accessor (cast to Float)
  lat:   ->(r) { r["lat"].to_f },  # Latitude accessor (cast to Float)
  icon:  "eiffel.jpg",             # Marker icon image
  label: ->(r) { r["name"] },      # Label text displayed next to the marker
  font:  "./fonts/DejaVuSans-Bold.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size:  14,                       # Label font size
  color: [0, 0, 0]                 # Label color (RGB)
)

# ---------------------------
# Render map
# ---------------------------
# Render the map using the configured basemap, style, and layers.
map.render

# Enable antialiasing for subsequent manual drawing operations
map.image.antialias = true

# ---------------------------
# Title overlay
# ---------------------------
# Draw a title overlay directly onto the rendered image.
# This demonstrates post-render drawing using libgd primitives.
font = "./fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path

bg = GD::Color.rgba(0, 0, 0, 100)
fg = GD::Color.rgb(255, 255, 255)

# Background rectangle for the title
map.image.filled_rectangle(30, 30, 330, 100, bg)

# Title text
map.image.text(
  "PARIS",
  x: 60,
  y: 85,
  size: 36,
  color: fg,
  font: font
)

# ---------------------------
# Save output
# ---------------------------
# Save the final rendered image to disk.
map.save("paris.png")

