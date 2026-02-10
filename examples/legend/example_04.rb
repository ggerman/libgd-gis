# frozen_string_literal: true

require "gd/gis"

# ------------------------------------------------------------
# STYLE
# ------------------------------------------------------------
style = GD::GIS::Style.load("light")

# ------------------------------------------------------------
# MAP — Paraná, Entre Ríos
# ------------------------------------------------------------
# Bounding box centrado en Paraná
bbox = [-60.60, -31.81, -60.46, -31.67]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 13,
  basemap: :osm,
  width: 800,
  height: 600
)

map.style = style

# ------------------------------------------------------------
# DATA — puntos de ejemplo en Paraná
# ------------------------------------------------------------

map.add_point(
  lon: -60.52897,
  lat: -31.73271,
  label: "Centro",
  color: [76, 175, 80, 0],
  symbol: 1
)

map.add_point(
  lon: -60.53,
  lat: -31.75,
  label: "Paracao",
  color: [255, 193, 7, 0],
  symbol: 2
)

map.add_point(
  lon: -60.50,
  lat: -31.72,
  label: "Tunel",
  color: [244, 67, 54, 0],
  symbol: 3
)

# ------------------------------------------------------------
# LEGEND
# ------------------------------------------------------------

map.legend(position: :bottom_right) do |l|
  l.add [76, 175, 80, 0],  "Centro"
  l.add [255, 193, 7, 0],  "Paracao"
  l.add [244, 67, 54, 0],  "Tunel"
end

# ------------------------------------------------------------
# RENDER
# ------------------------------------------------------------

map.render

# ------------------------------------------------------------
# POLAROID FRAME
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
# CAPTION
# ------------------------------------------------------------

font = GD::GIS::FontHelper.find("Lato") ||
       GD::GIS::FontHelper.random

final.text_ft(
  "Paraná, ER — Ejemplo de Mapa",
  x: 30,
  y: final.height - 25,
  font: font,
  size: 12,
  color: GD::Color.rgb(80, 80, 80)
)

# ------------------------------------------------------------
# SAVE
# ------------------------------------------------------------

final.save("example_parana_polaroid.png")

puts "✔ Mapa de Paraná generado como example_parana_polaroid.png"
