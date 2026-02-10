# frozen_string_literal: true

require "gd/gis"

# ------------------------------------------------------------
# STYLE
# ------------------------------------------------------------
style = GD::GIS::Style.load("light")

# ------------------------------------------------------------
# MAP — PARIS
# ------------------------------------------------------------
# Bounding box aproximado de París
bbox = [2.25, 48.82, 2.42, 48.90]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 13,
  basemap: :osm,
  width: 800,
  height: 600
)

map.style = style

# ------------------------------------------------------------
# DATA — logistics status (Paris)
# ------------------------------------------------------------

map.add_point(
  lon: 2.3522,   # Notre Dame
  lat: 48.8566,
  label: "Delivered",
  color: [76, 175, 80, 0],
  symbol: 1
)

map.add_point(
  lon: 2.2945,   # Eiffel Tower
  lat: 48.8584,
  label: "In transit",
  color: [255, 193, 7, 0],
  symbol: 2
)

map.add_point(
  lon: 2.3730,   # Bastille
  lat: 48.8530,
  label: "Delayed",
  color: [244, 67, 54, 0],
  symbol: 3
)

# ------------------------------------------------------------
# LEGEND
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
  "Paris — Logistics Status",
  x: 30,
  y: final.height - 25,
  font: font,
  size: 12,
  color: GD::Color.rgb(80, 80, 80)
)

# ------------------------------------------------------------
# SAVE
# ------------------------------------------------------------

final.save("example_03a_paris_polaroid.png")

puts "✔ rendered example_03a_paris_polaroid.png"
