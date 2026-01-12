require "gd/gis"

MANHATTAN = [-74.05, 40.70, -73.93, 40.88]

map = GD::GIS::Map.new(
  bbox: MANHATTAN,
  zoom: 13,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("dark")

# capas
map.add_geojson("nyc_test.geojson")

# POIs
pois = [
  { "name" => "Manhattan",     "lon" => -73.97, "lat" => 40.78 },
  { "name" => "Brooklyn",      "lon" => -73.95, "lat" => 40.65 },
  { "name" => "Queens",        "lon" => -73.85, "lat" => 40.73 },
  { "name" => "Bronx",         "lon" => -73.86, "lat" => 40.85 },
  { "name" => "Staten Island", "lon" => -74.15, "lat" => 40.58 }
]

font = "./fonts/DejaVuSans-Bold.ttf" # Use a system font or copy a .ttf into your project and reference it by path

map.add_points(
  pois,
  lon:   ->(r){ r["lon"] },
  lat:   ->(r){ r["lat"] },
  icon:  "icon.png",
  label: ->(r){ r["name"] },
  font:  font,
  size:  14,
  color: [0,0,0]
)

# UNA sola vez
map.render

map.image.antialias = true

bg = GD::Color.rgba(0,0,0,120)
fg = GD::Color.rgb(255,255,255)

map.image.filled_rectangle(30, 30, 520, 120, bg)
map.image.text("NEW YORK CITY", x: 60, y: 95, size: 36, color: fg, font: font)

map.save("nyc.png")
