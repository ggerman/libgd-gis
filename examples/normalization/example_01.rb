# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"

map = GD::GIS::Map.new(
  bbox: [-74.05, 40.70, -73.93, 40.88],
  zoom: 14,
  width: 800,
  height: 600,
  basemap: :carto_light
)

puts map.instance_variable_get(:@bbox)


