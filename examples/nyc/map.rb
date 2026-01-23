require "gd/gis"

# ---------------------------
# Manhattan bounding box
# ---------------------------
# Geographic extent covering Manhattan and surrounding boroughs
# (WGS84 longitude/latitude)
MANHATTAN = [-74.05, 40.70, -73.93, 40.88]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: MANHATTAN,
  zoom: 13,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# This example uses a predefined dark style.
map.style = GD::GIS::Style.load("dark")

# ---------------------------
# Load GeoJSON layers
# ---------------------------
# Load mixed geometries (e.g. administrative areas, land use, or roads)
# from a GeoJSON file.
map.add_geojson("nyc_test.geojson")

# ---------------------------
# Points of interest (POIs)
# ---------------------------
# Define a set of labeled points representing New York City boroughs.
pois = [
  { "name" => "Manhattan",     "lon" => -73.97, "lat" => 40.78 },
  { "name" => "Brooklyn",      "lon" => -73.95, "lat" => 40.65 },
  { "name" => "Queens",        "lon" => -73.85, "lat" => 40.73 },
  { "name" => "Bronx",         "lon" => -73.86, "lat" => 40.85 },
  { "name" => "Staten Island", "lon" => -74.15, "lat" => 40.58 }
]

# Font used for POI labels
font = "./fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path

# ---------------------------
# Add POI layer
# ---------------------------
# Adds a points overlay representing the borough labels.
# Each point is rendered with a custom icon and text label.
map.add_points(
  pois,
  lon:   ->(r) { r["lon"] },   # Longitude accessor
  lat:   ->(r) { r["lat"] },   # Latitude accessor
  icon:  "icon.png",           # Marker icon image
  label: ->(r) { r["name"] },  # Label text
  font:  font,                 # Font used for labels
  size:  14,                   # Label font size
  color: [0, 0, 0]             # Label color (RGB)
)

# ---------------------------
# Render map (single pass)
# ---------------------------
# Render the map once using the configured basemap, style, and layers.
# Subsequent drawing operations are performed directly on the image.
map.render

# Enable antialiasing for post-render drawing
map.image.antialias = true

# ---------------------------
# Title overlay
# ---------------------------
# Draw a semi-transparent background box and render a title label
# directly onto the rendered image.
bg = GD::Color.rgba(0, 0, 0, 120)
fg = GD::Color.rgb(255, 255, 255)

map.image.filled_rectangle(30, 30, 520, 120, bg)
map.image.text(
  "NEW YORK CITY",
  x: 60,
  y: 95,
  size: 36,
  color: fg,
  font: font
)

# ---------------------------
# Save output
# ---------------------------
# Save the final rendered image to disk.
map.save("nyc.png")

