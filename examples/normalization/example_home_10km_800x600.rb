# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"
require_relative "fonts"

# --------------------------------------------------
# Home coordinates (lon, lat)
# --------------------------------------------------
HOME = [-60.52903026, -31.77034026]

# --------------------------------------------------
# Compute 10 km radius bbox
# --------------------------------------------------
lat = HOME[1]

delta_lat = 10.0 / 111.0
delta_lon = 10.0 / (111.0 * Math.cos(lat * Math::PI / 180))

BBOX_10KM = [
  HOME[0] - delta_lon,
  HOME[1] - delta_lat,
  HOME[0] + delta_lon,
  HOME[1] + delta_lat
]

GEOJSON = "data/casa_cerveceria.geojson"

# This way allow the use of witdht and height in Map.new
BBOX_PARANA_SANTA_FE = [
  -61.05,  # min_lng
  -32.10,  # min_lat
  -60.35,  # max_lng
  -31.40   # max_lat
]

# --------------------------------------------------
# Create map (viewport rendering)
# --------------------------------------------------
map = GD::GIS::Map.new(
  bbox: BBOX_PARANA_SANTA_FE,
  zoom: 11,
  basemap: :esri_satellite,
  width: 800,
  height: 600
)
# --------------------------------------------------
# Minimal style stub (no overlays yet)
# --------------------------------------------------
map.style = GD::GIS::Style.load("solarized")

map.add_geojson(GEOJSON)
layers = map.instance_variable_get(:@layers)

puts "LAYERS CONTENT:"

layers.each { |k,v| puts "#{k}: #{v.size}" }
pois = [
  {
    "name" => "Mi Casa",
    "lon"  => HOME[0],
    "lat"  => HOME[1]
  }
]

map.add_points(
  pois,
  lon:   ->(r){ r["lon"] },
  lat:   ->(r){ r["lat"] },
  label: ->(r){ r["name"] },
  icon:  nil,
  font:  GD::Fonts.random,
  size:  20,
  color: [0, 0, 0]
)

last = map.instance_variable_get(:@layers)[:minor].last.instance_variable_get(:@geometry)["coordinates"][0].last
puts last

pois = [
  {
    "name" => "Cerveceria",
    "lon"  => last[0],
    "lat"  => last[1]
  }
]

map.add_points(
  pois,
  lon:   ->(r){ r["lon"] },
  lat:   ->(r){ r["lat"] },
  label: ->(r){ r["name"] },
  icon:  "beer.png",
  font:  GD::Fonts.random,
  size:  20
)

# --------------------------------------------------
# Render basemap
# --------------------------------------------------
map.render

map.image.antialias = true
# --------------------------------------------------
# Save
# --------------------------------------------------
map.save("output/a-n201234.png")

