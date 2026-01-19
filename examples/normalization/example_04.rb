# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"

# --------------------------------------------------
# World bbox (WGS84)
# --------------------------------------------------
WORLD = [-180, -90, 180, 90]

# --------------------------------------------------
# Create map (viewport-based rendering)
# --------------------------------------------------
map = GD::GIS::Map.new(
  bbox: WORLD,
  zoom: 2,
  basemap: :esri_hybrid,
  width: 640,
  height: 480
)

# --------------------------------------------------
# Minimal style (required by render, but unused here)
# --------------------------------------------------
map.style = Struct.new(:order, :roads, :rails, :water, :parks).new(
  [], {}, nil, nil, nil
)

# --------------------------------------------------
# Render and save
# --------------------------------------------------
map.render

map.save("output/world_satellite_640x480.png")

