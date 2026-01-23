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
# Load GeoJSON data
# ---------------------------
# Load water-related line geometries (e.g. rivers, canals) from a GeoJSON file.
# Features are classified internally using the ontology and style rules.
map.add_geojson("water_lines.geojson")

# ---------------------------
# Load external style
# ---------------------------
# A style is mandatory for rendering.
# This example uses an externally defined dark style.
map.style = GD::GIS::Style.load("dark")

# ---------------------------
# Render and save
# ---------------------------
# Render the map using the configured basemap, style, and layers,
# then save the resulting image to disk.
map.render
map.save("tokyo_water.png")

