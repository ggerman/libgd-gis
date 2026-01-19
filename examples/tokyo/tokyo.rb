# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"
require "gd"

TOKYO = [139.68, 35.63, 139.82, 35.75]

map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :esri_satellite
)

map.style = GD::GIS::Style.load("solarized")

map.add_geojson("railways.geojson")
map.add_geojson("parks.geojson")
map.add_geojson("wards.geojson")

map.render
map.save("tokyo.png")

# --------------------------
# Overlay label
# --------------------------

img = GD::Image.open("tokyo.png")

font = "../fonts/DejaVuSans-Bold.ttf"
text = "TOKYO"

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

img.save("tokyo.png")
