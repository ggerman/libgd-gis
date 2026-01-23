require "csv"
require "gd/gis"

# ---------------------------
# Paraná bounding box
# ---------------------------
# Geographic extent covering a portion of the city of Paraná
# (WGS84 longitude/latitude)
PARANA = [-60.56, -31.76, -60.50, -31.71]

# ---------------------------
# Create map
# ---------------------------
# Initializes a GD::GIS::Map instance using a light CARTO basemap.
# Tile-based rendering is used because width and height are not specified.
map = GD::GIS::Map.new(
  bbox: PARANA,
  zoom: 15,
  basemap: :carto_light
)

# ---------------------------
# Load style
# ---------------------------
# A style is mandatory for rendering.
# This example uses the default external style definition.
map.style = GD::GIS::Style.load("default", from: "styles")

# ---------------------------
# Load street data
# ---------------------------
# Load street geometries from a GeoJSON file.
# A custom color is provided for rendering the street network.
map.add_geojson(
  "parana_streets.geojson",
  color: [250, 0, 0]
)

# ---------------------------
# Museums from CSV
# ---------------------------
# Load museum data from a CSV file.
# The file is expected to include latitude, longitude, and name columns.
museos = CSV.read("museums.csv", headers: true)

# ---------------------------
# Bounding box filter
# ---------------------------
# Select only museums that fall within the Paraná bounding box.
# This is useful for debugging or data validation.
PARANA = [-60.56, -31.76, -60.50, -31.71]

museos = CSV.read("museums.csv", headers: true)

en_bbox = museos.select do |r|
  lon = r["Longitud"].to_f
  lat = r["Latitud"].to_f

  lon >= PARANA[0] && lon <= PARANA[2] &&
  lat >= PARANA[1] && lat <= PARANA[3]
end

# Print diagnostic information about filtered museums
puts "Museums in bbox: #{en_bbox.size}"
puts en_bbox.first(10).map { |r| "#{r['nombre']} (#{r['Latitud']}, #{r['Longitud']})" }

# ---------------------------
# Add museums layer
# ---------------------------
# Add a points overlay representing museums.
# Each museum is rendered using a custom icon and a text label.
map.add_points(
  museos,
  lon: ->(r) { r["Longitud"].to_f }, # Longitude accessor
  lat: ->(r) { r["Latitud"].to_f },  # Latitude accessor
  icon: "museum.png",                # Marker icon image
  label: ->(r) { r["nombre"] },      # Label text
  font: "./fonts/DejaVuSans.ttf",    # Use a system font or copy a .ttf into your project and reference it by path
  size: 12,                          # Label font size
  color: [40, 40, 40]                # Label color (RGB)
)

# ---------------------------
# Render and save
# ---------------------------
# Render the map with the configured basemap, style, and layers,
# then save the resulting image to disk.
map.render
map.save("parana.png")

