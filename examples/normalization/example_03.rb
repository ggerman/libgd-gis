# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"

# --------------------------------------------------
# Define area (Paris)
# --------------------------------------------------
PARIS = [2.25, 48.80, 2.42, 48.90]

# --------------------------------------------------
# Create map with fixed viewport size
# --------------------------------------------------
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light,
  width: 350,
  height: 350
)

# --------------------------------------------------
# Optional style
# --------------------------------------------------
map.style = GD::GIS::Style.load("solarized")

# --------------------------------------------------
# Optional vector data
# --------------------------------------------------
map.add_geojson("data/seine.geojson")
map.add_geojson("data/parks.geojson")

# --------------------------------------------------
# Render and save
# --------------------------------------------------
map.render
map.save("output/paris_350x350.png")

