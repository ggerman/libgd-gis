require "json"
require "gd/gis"

geo = JSON.parse(File.read("./hydro_plants.geojson"))
plants = geo["features"]

lons = []
lats = []

plants.each do |f|
  lon, lat = f["geometry"]["coordinates"]
  lons << lon
  lats << lat
end

bbox = [lons.min, lats.min, lons.max, lats.max]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 7,
  basemap: :carto_light
)

map.add_points(
  plants,
  lon: ->(f){ f["geometry"]["coordinates"][0] },
  lat: ->(f){ f["geometry"]["coordinates"][1] },
  icon: "hydro.png"
)

map.render
map.save("tanzania_hydro.png")
