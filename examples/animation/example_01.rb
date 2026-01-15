require "json"
require "gd/gis"

NYC = [-74.05, 40.68, -73.85, 40.85]

def load_route(path)
  GD::GIS::PathSampler.from_geojson(path)
end

map = GD::GIS::Map.new(
  bbox: NYC,
  zoom: 13,
  basemap: :carto_dark
)

map.style = GD::GIS::Style.load("dark")
map.add_geojson "geojson/nyc_roads.geojson"

car = load_route("car.json")

# create ONE car layer
car_layer = map.add_points(
  [{ "geometry" => { "coordinates" => car.point_at(0) } }],
  lon: ->(f){ f["geometry"]["coordinates"][0] },
  lat: ->(f){ f["geometry"]["coordinates"][1] },
  icon: "car.png"
)

gif = GD::Gif.new("nyc_car_01.gif")
frames = 60

frames.times do |i|
  t = i.to_f / (frames - 1)

  # update car position
  lon,lat = car.point_at(t)
  car_layer.data = [{ "geometry" => { "coordinates" => [lon,lat] }}]

  img = map.render
  gif.add_frame(img, delay: 5)
end

gif.close
