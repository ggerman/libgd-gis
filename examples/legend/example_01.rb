# frozen_string_literal: true

require "gd/gis"

def polaroid_frame(image,
                   margin: 20,
                   bottom_margin: 60,
                   bg_color: [255, 255, 255, 0])

  new_width  = image.width  + margin * 2
  new_height = image.height + margin + bottom_margin

  framed = GD::Image.new(new_width, new_height)
  framed.antialias = false

  bg = GD::Color.rgba(*bg_color)
  framed.filled_rectangle(0, 0, new_width, new_height, bg)

  # copy original map
  framed.copy(
    image,
    margin,
    margin,
    0, 0,
    image.width,
    image.height
  )

  framed
end

style = GD::GIS::Style.load("light")

bbox = [-58.55, -34.75, -58.35, -34.55]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 12,
  basemap: :osm,
  width: 800,
  height: 600
)

map.style = style

# --- DATA --------------------------------------------------

map.add_point(
  lon: -58.3816,
  lat: -34.6037,
  label: "Delivered",
  color: [76, 175, 80, 0],
  symbol: 1
)

map.add_point(
  lon: -58.3916,
  lat: -34.6137,
  label: "In transit",
  color: [255, 193, 7, 0],
  symbol: 2
)

map.add_point(
  lon: -58.4016,
  lat: -34.5937,
  label: "Delayed",
  color: [244, 67, 54, 0],
  symbol: 3
)

# --- LEGEND (solo datos, nada visual) ----------------------

map.legend do |l|
  l.add [76, 175, 80, 0],  "Delivered"
  l.add [255, 193, 7, 0],  "In transit"
  l.add [244, 67, 54, 0],  "Delayed"
end

# --- RENDER ------------------------------------------------

map.render

map_with_frame = polaroid_frame(
  map.image,
  margin: 20,
  bottom_margin: 70
)

map_with_frame.save("example_01.png")

puts "✔ rendered example_01.png"
