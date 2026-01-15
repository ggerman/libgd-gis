require "json"
require "gd/gis"

NYC = [-74.05, 40.68, -73.85, 40.85]

# Web profile
FRAMES = 30
DELAY  = 10

map = GD::GIS::Map.new(
  bbox: NYC,
  zoom: 13,
  basemap: :carto_dark
)

map.style = GD::GIS::Style.load("dark")

# Only main roads for better compression
map.add_geojson "geojson/nyc_roads.geojson"

car   = GD::GIS::PathSampler.from_geojson("car.json")
plane = GD::GIS::PathSampler.from_geojson("plain.json")

# One layer per moving object
car_layer = map.add_points(
  [{ "geometry" => { "coordinates" => car.point_at(0) } }],
  lon: ->(f){ f["geometry"]["coordinates"][0] },
  lat: ->(f){ f["geometry"]["coordinates"][1] },
  icon: "car.png"
)

plane_layer = map.add_points(
  [{ "geometry" => { "coordinates" => plane.point_at(0) } }],
  lon: ->(f){ f["geometry"]["coordinates"][0] },
  lat: ->(f){ f["geometry"]["coordinates"][1] },
  icon: "plane.png"
)

gif = GD::Gif.new("nyc_car_plane.gif")

FRAMES.times do |i|
  t = i.to_f / (FRAMES - 1)

  # update positions
  lon,lat = car.point_at(t)
  car_layer.data = [{ "geometry" => { "coordinates" => [lon,lat] }}]

  lon,lat = plane.point_at(t)
  plane_layer.data = [{ "geometry" => { "coordinates" => [lon,lat] }}]

  img = map.render

  gif.add_frame(img, delay: DELAY)
end

gif.close

puts "Generated nyc_car_plane_04.gif"
