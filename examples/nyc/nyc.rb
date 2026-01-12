require "gd/gis"

NYC = [-74.02, 40.70, -73.93, 40.82]
ZOOM = 14

map = GD::GIS::Map.new(
  bbox: NYC,
  zoom: ZOOM,
  basemap: :carto_light
)

# Streets
map.add_geojson(
  "streets.geojson",
  color: [250,0,0]
)

# Parks
map.add_geojson(
  "parks.geojson",
  color: [170,210,170]
)

# Boroughs
map.add_geojson(
  "boroughs.geojson",
  color: [180,180,220]
)

map.render
map.save("nyc.png")

# --------------------------
# Overlay label
# --------------------------

img = GD::Image.open("nyc.png")

font = "../fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path
text = "New York"

x = 24
y = 24
w = 300
h = 64

# Fondo
img.filled_rectangle(x, y, x + w, y + h, [0,0,0])

# Texto
img.text(
  text,
  x: x + 24,
  y: y + 44,
  size: 32,
  color: [255,255,255],
  font: font
)

img.save("nyc.png")
