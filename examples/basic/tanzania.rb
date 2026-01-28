# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# ---------------------------
# Load GeoJSON data
# ---------------------------
# Read a GeoJSON file containing hydroelectric plant point features
geo = JSON.parse(File.read("./hydro_plants.geojson"))
plants = geo["features"]

# ---------------------------
# Compute bounding box
# ---------------------------
# Extract longitude and latitude values from all features
# in order to compute an automatic bounding box
lons = []
lats = []

plants.each do |f|
  lon, lat = f["geometry"]["coordinates"]
  lons << lon
  lats << lat
end

# Bounding box derived from the feature extents (WGS84 lon/lat)
bbox = [lons.min, lats.min, lons.max, lats.max]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: bbox,
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
# Add hydro plants layer
# ---------------------------
# Adds a points overlay representing hydroelectric power plants.
# Each plant is rendered using a custom icon.
map.add_points(
  plants,
  lon: ->(f) { f["geometry"]["coordinates"][0] }, # Longitude accessor
  lat: ->(f) { f["geometry"]["coordinates"][1] }, # Latitude accessor
  icon: "hydro.png"                                # Marker icon image
)

# ---------------------------
# Render and save
# ---------------------------
# Render the map with the configured basemap, style, and layers,
# then save the resulting image to disk.
map.render
map.save("tanzania_hydro.png")

