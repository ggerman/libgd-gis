require "json"
require "csv"
require "gd/gis"

map = GD::GIS::Map.new(
  bbox: [-73.6, -55.1, -53.6, -21.8],
  zoom: 7,
  basemap: :carto_light
)

map.add_points(
  JSON.parse(File.read("localidades.json"))["localidades"],
  lon: ->(r){ r["centroide"]["lon"] },
  lat: ->(r){ r["centroide"]["lat"] },
  icon: "flag.png"
)

map.render
map.save("argentina.png")
