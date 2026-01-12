require "gd/gis"
require "pry"

PARIS = [2.25, 48.80, 2.42, 48.90]

map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("solarized")


# Seine river
map.add_geojson("data/seine.geojson")

# Parks
map.add_geojson("data/parks.geojson")


pois = [
  { "name" => "Eiffel Tower", "lon" => 2.2945, "lat" => 48.8584 }
]

map.add_points(
  pois,
  lon:   ->(r){ r["lon"].to_f },
  lat:   ->(r){ r["lat"].to_f },
  icon:  "eiffel.jpg",
  label: ->(r){ r["name"] },
  font:  "./fonts/DejaVuSans-Bold.ttf", # Use a system font or copy a .ttf into your project and reference it by path
  size:  14,
  color: [0,0,0]
)

map.render
map.image.antialias = true

# Title
font = "./fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path

bg = GD::Color.rgba(0,0,0,100)
fg = GD::Color.rgb(255,255,255)

map.image.filled_rectangle(30, 30, 330, 100, bg)
map.image.text("PARIS", x: 60, y: 85, size: 36, color: fg, font: font)

map.save("paris.png")
