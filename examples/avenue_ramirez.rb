# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

# Paraná bbox
BBOX = [-60.556640625, -31.8402326679, -60.46875, -31.6907818061]

map = GD::GIS::Map.new(
  bbox: BBOX,
  zoom: 14,
  basemap: :esri_satellite
)

geo = JSON.parse(File.read("ramirez_full.geojson"))
features = geo["features"]

map.add_lines(
  features,
  stroke: [0, 0, 0, 90],       # borde
  fill:   [0, 0, 0, 90],   # calzada
  width:  50                   # ancho en metros
)

map.add_lines(
  features,
  stroke: [255, 165, 0, 90],
  width:  2
)

# Label
map.add_points(
  [{ lon: -60.5205, lat: -31.76, name: "Av. Ramírez" }],
  lon: ->(p){ p[:lon] },
  lat: ->(p){ p[:lat] },
  label: ->(p){ p[:name] },
  font: "./fonts/DejaVuSans.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size: 16,
  color: [0,0,0,160],
  icon: "mark.png"
)

map.render
map.save("ramirez_gis.png")

puts "Generated ramirez_gis.png"
