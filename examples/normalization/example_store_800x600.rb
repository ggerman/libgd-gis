# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"
require_relative "fonts"
require "pry"

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

STORE = [-60.69128666, -31.64296384]

bbox = GD::GIS::Geometry.bbox_around_point(STORE[0], STORE[1], radius_km: 0.5)

# --------------------------------------------------
# Create map (viewport rendering)
# --------------------------------------------------
map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 17,
  basemap: :cyclosm,
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

last = map.features_by_layer(:minor).last
store = last.geometry["coordinates"][0].last
puts cerveceria

pois = [
  {
    "name" => "Store",
    "lon"  => store[0],
    "lat"  => store[1]
  }
]

map.add_points(
  pois,
  lon:   ->(r){ r["lon"] },
  lat:   ->(r){ r["lat"] },
  label: ->(r){ r["name"] },
  icon:  "beer.png",
  font:  GD::Fonts.random,
  size:  20,
	color: [250, 250, 250]
)

# --------------------------------------------------
# Render basemap
# --------------------------------------------------
map.render

map.image.filter(:sepia)

# --------------------------------------------------
# Save
# --------------------------------------------------
map.save("output/s1.png")

