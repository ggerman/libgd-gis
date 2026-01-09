require "gd/gis"

PARIS = [2.224, 48.815, 2.469, 48.902]

map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 12,
  basemap: :carto_light
)

map.add_geojson(
  "streets.geojson",
  color: [17,55,85]
)

map.render
map.save("paris.png")

# --------------------------
# Overlay label
# --------------------------

img = GD::Image.open("paris.png")

font = "../fonts/DejaVuSans-Bold.ttf"
text = "Paris"

x = 24
y = 24
w = 240
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

img.save("paris.png")
