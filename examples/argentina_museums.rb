# libgd-gis is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "csv"
require "gd"

ZOOM = 7
TILE_SIZE = 256

# Bounding box Argentina (igual que en argentina_tiles.rb)
WEST  = -73.6
EAST  = -53.6
NORTH = -21.8
SOUTH = -55.1

def lon2tile(lon, z)
  ((lon + 180.0) / 360.0 * (2 ** z)).floor
end

def lat2tile(lat, z)
  rad = lat * Math::PI / 180
  ((1 - Math.log(Math.tan(rad) + 1 / Math.cos(rad)) / Math::PI) / 2 * (2 ** z)).floor
end

def lon2px(lon, z)
  ((lon + 180.0) / 360.0 * (256 * 2**z))
end

def lat2px(lat, z)
  rad = lat * Math::PI / 180
  ((1 - Math.log(Math.tan(rad) + 1 / Math.cos(rad)) / Math::PI) / 2 * (256 * 2**z))
end

# Same tile bbox used to build argentina.png
x_min = lon2tile(WEST,  ZOOM)
y_min = lat2tile(NORTH, ZOOM)

offset_x = x_min * TILE_SIZE
offset_y = y_min * TILE_SIZE

# Load map
img = GD::Image.open("output/argentina.png")

# Load icon
icon = GD::Image.open("museos.png")
iw = icon.width
ih = icon.height

puts "Plotting museums..."

CSV.foreach("museos_datosabiertos.csv", headers: true, encoding: "bom|utf-8") do |row|
  next if row["Latitud"].nil? || row["Longitud"].nil?

  lat = row["Latitud"].to_f
  lon = row["Longitud"].to_f

  # global pixel in Web Mercator
  px = lon2px(lon, ZOOM)
  py = lat2px(lat, ZOOM)

  # local pixel inside argentina.png
  x = px - offset_x
  y = py - offset_y

  # skip if outside raster
  next if x < 0 || y < 0 || x >= img.width || y >= img.height

  img.copy(icon, x.to_i - iw/2, y.to_i - ih/2, 0, 0, iw, ih)
end

img.save("output/argentina_museums.png")
puts "Saved output/argentina_museums.png"
