require "json"
require "gd/gis"

def draw_legend(img)
  padding = 10
  x = 20
  y = 20
  w = 380
  h = 70

  bg = GD::Color.rgba(0,0,0,180)
  border = GD::Color.rgb(255,255,255)
  text1 = GD::Color.rgb(255,255,255)
  text2 = GD::Color.rgb(180,220,255)

  # fondo
  img.filled_rectangle(x, y, x+w, y+h, bg)
  img.rectangle(x, y, x+w, y+h, border)

  img.text(
    "libgd-gis v0.2.7",
    x: x + padding,
    y: y + 28,
    size: 20,
    color: text1,
    font: "fonts/DejaVuSans-Bold.ttf"
  )

  img.text(
    "Animated GIS engine for Ruby",
    x: x + padding,
    y: y + 52,
    size: 14,
    color: text2,
    font: "fonts/DejaVuSans.ttf"
  )
end


NYC = [-74.05, 40.68, -73.85, 40.85]

map = GD::GIS::Map.new(
  bbox: NYC,
  zoom: 13,
  basemap: :esri_streets
)

map.style = GD::GIS::Style.load("dark")
map.add_geojson "geojson/nyc_roads.geojson"

# 🔒 Render static base ONCE
map.render_base

car   = GD::GIS::PathSampler.from_geojson("car.json")
plane = GD::GIS::PathSampler.from_geojson("plain.json")

landing_lon, landing_lat = plane.point_at(1.0)

map.add_points(
  [{ "geometry" => { "coordinates" => [landing_lon, landing_lat] }}],
  lon: ->(f){ f["geometry"]["coordinates"][0] },
  lat: ->(f){ f["geometry"]["coordinates"][1] },
  icon: "airport.png"
)

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

gif = GD::Gif.new("nyc_car_plane_label.gif")
frames = 60

frames.times do |i|
  t = i.to_f / (frames - 1)

  car_layer.data = [{ "geometry" => { "coordinates" => car.point_at(t) }}]
  plane_layer.data = [{ "geometry" => { "coordinates" => plane.point_at(t) }}]

  img = map.render_with_base
  draw_legend(img)
  gif.add_frame(img, delay: 5)
end

gif.close
