require "gd/gis"

BBOX = [-60.53, -31.77, -60.51, -31.74]

map = GD::GIS::Map.new(
  bbox: BBOX,
  zoom: 15,
  basemap: :carto_dark
)

polygon = [
  [-60.525, -31.750],
  [-60.520, -31.750],
  [-60.520, -31.755],
  [-60.525, -31.755],
  [-60.525, -31.750]
]

map.add_polygons(
  [polygon],
  fill:   [255, 140, 0, 120],
  stroke: [0, 0, 0, 200],
  width:  2
)

map.render
map.save("carto_dark.png")

puts "Generated carto_dark.png"
