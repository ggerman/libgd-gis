# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "json"
require "gd/gis"

EUROPE = [-15.0, 34.0, 40.0, 72.0]

map = GD::GIS::Map.new(
  bbox: EUROPE,
  zoom: 4,
  basemap: :carto_light
)


peaks = JSON.parse(File.read("picks.json"))

map.add_points(
  peaks,
  lon: ->(p) { p["longitude"] },
  lat: ->(p) { p["latitude"] },
  icon: "peak.png",
  label: ->(p) { p["name"] },
  font: "./fonts/DejaVuSans.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size: 10,
  color: [0,0,0]
)

map.render
map.save("output/europe.png")

puts "Saved output/europe.png"
