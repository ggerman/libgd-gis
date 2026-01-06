require "json"
require "gd"

# --------------------------------
# Input / output
# --------------------------------
BASE_MAP = "output/argentina.png"
DATA     = "localidades.json"
OUTPUT   = "output/argentina_localidades.png"

# --------------------------------
# Bounding box de Argentina (WGS84)
# --------------------------------
ARG_MIN_LON = -73.6
ARG_MAX_LON = -53.6
ARG_MIN_LAT = -55.1
ARG_MAX_LAT = -21.8

R = 6378137.0

def mercator_x(lon)
  lon * Math::PI / 180.0 * R
end

def mercator_y(lat)
  Math.log(Math.tan(Math::PI/4 + lat * Math::PI / 360.0)) * R
end

# --------------------------------
# Cargar mapa base
# --------------------------------
img = GD::Image.open(BASE_MAP)

width  = img.width
height = img.height

flag = GD::Image.open("flag.png")
flag_w = flag.width
flag_h = flag.height

# --------------------------------
# Bounding box proyectado
# --------------------------------
min_x = mercator_x(ARG_MIN_LON)
max_x = mercator_x(ARG_MAX_LON)
min_y = mercator_y(ARG_MIN_LAT)
max_y = mercator_y(ARG_MAX_LAT)

def lonlat_to_pixel(lon, lat, min_x, max_x, min_y, max_y, width, height)
  x = mercator_x(lon)
  y = mercator_y(lat)

  px = (x - min_x) / (max_x - min_x) * width
  py = height - (y - min_y) / (max_y - min_y) * height

  [px.to_i, py.to_i]
end

# --------------------------------
# Cargar localidades
# --------------------------------
data = JSON.parse(File.read(DATA))

red = GD::Color.rgb(220, 40, 40)

puts "Plotting #{data["localidades"].size} localidades..."

data["localidades"].each do |loc|
  lon = loc["centroide"]["lon"]
  lat = loc["centroide"]["lat"]

  x, y = lonlat_to_pixel(lon, lat, min_x, max_x, min_y, max_y, width, height)

  # dibujar un punto
    img.copy(
        flag,
        x - flag_w / 2,
        y - flag_h / 2,
        0, 0,
        flag_w,
        flag_h
    )
end

# --------------------------------
# Guardar resultado
# --------------------------------
img.save(OUTPUT)
puts "Saved #{OUTPUT}"
