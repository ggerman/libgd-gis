# frozen_string_literal: true

require "gd/gis"

# ------------------------------------------------------------
# STYLE
# ------------------------------------------------------------
# Usa un style que DEFINA point.font y point.size
style = GD::GIS::Style.load("light")

# ------------------------------------------------------------
# MAP
# ------------------------------------------------------------
bbox = [-58.55, -34.75, -58.35, -34.55]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 12,
  basemap: :osm,
  width: 800,
  height: 600
)

map.style = style

# ------------------------------------------------------------
# DATA — status logístico
# ------------------------------------------------------------

map.add_point(
  lon: -58.3816,
  lat: -34.6037,
  label: "Delivered",
  color: [76, 175, 80, 0],
  symbol: 1
)

map.add_point(
  lon: -58.3920,
  lat: -34.6150,
  label: "In transit",
  color: [255, 193, 7, 0],
  symbol: 2
)

map.add_point(
  lon: -58.4050,
  lat: -34.5900,
  label: "Delayed",
  color: [244, 67, 54, 0],
  symbol: 3
)

# ------------------------------------------------------------
# LEGEND (solo datos)
# ------------------------------------------------------------

map.legend(position: :bottom_right) do |l|
  l.add [76, 175, 80, 0],  "Delivered"
  l.add [255, 193, 7, 0],  "In transit"
  l.add [244, 67, 54, 0],  "Delayed"
end

# ------------------------------------------------------------
# RENDER
# ------------------------------------------------------------

map.render

# ------------------------------------------------------------
# POLAROID FRAME (post-procesado)
# ------------------------------------------------------------

def polaroid_frame(image,
                   margin: 20,
                   bottom_margin: 70,
                   bg_color: [255, 255, 255, 0])

  framed = GD::Image.new(
    image.width  + margin * 2,
    image.height + margin + bottom_margin
  )

  framed.antialias = false

  bg = GD::Color.rgba(*bg_color)
  framed.filled_rectangle(
    0, 0,
    framed.width,
    framed.height,
    bg
  )

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

final = polaroid_frame(map.image)

# ------------------------------------------------------------
# CAPTION (opcional pero queda muy bien)
# ------------------------------------------------------------

font = GD::GIS::FontHelper.find("Lato") ||
       GD::GIS::FontHelper.random

final.text_ft(
  "Buenos Aires — Logistics Status",
  x: 30,
  y: final.height - 25,
  font: font,
  size: 12,
  color: GD::Color.rgb(80, 80, 80)
)

# ------------------------------------------------------------
# SAVE
# ------------------------------------------------------------

final.save("example_02_logistics_polaroid.png")

puts "✔ rendered example_02_logistics_polaroid.png"
