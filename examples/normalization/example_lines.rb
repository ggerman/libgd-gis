# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"

bbox = [-74.05, 40.70, -73.95, 40.80]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 10,
  basemap: :carto_light,
  width: 800,
  height: 800
)

map.style = GD::GIS::Style.load("light")

lines = [
  [
    [-74.02, 40.71],
    [-74.00, 40.73],
    [-73.98, 40.75]
  ]
]

map.add_lines(
  lines,
  stroke: [239, 68, 68],
  width: 3
)

map.render
map.save("output/lines.png")
