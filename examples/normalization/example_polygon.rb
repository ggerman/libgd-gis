# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"

bbox = [-74.05, 40.68, -73.95, 40.78]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 10,
  basemap: :carto_light,
  width: 800,
  height: 800
)

map.style = GD::GIS::Style.load("dark")

polygons = [
  [
    [
      [-74.01, 40.70],
      [-74.00, 40.70],
      [-74.00, 40.71],
      [-74.05, 41.02],
      [-74.01, 40.71],
      [-74.01, 40.70]
    ]
  ]
]

map.add_polygons(
  polygons,
  fill:   [34, 197, 94, 180],  # verde con alpha
  stroke: [16, 185, 129],
  width:  2
)

map.render

map.save("output/polygons.png")
