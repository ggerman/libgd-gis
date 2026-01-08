require "csv"
require "gd/gis"

# --------------------------------
# Paraná, Entre Ríos
# --------------------------------
CITY = [-60.56, -31.76, -60.50, -31.71]

map = GD::GIS::Map.new(
  bbox: CITY,
  zoom: 15,
  basemap: :carto_light
)

# --------------------------------
# Cargar CSV oficial
# --------------------------------
rows = CSV.read("museums.csv", headers: true)

museos = rows.select do |r|
  r["localidad"]&.downcase == "paraná" &&
  r["Latitud"] &&
  r["Longitud"]
end

puts "Museums: #{museos.size}"

# --------------------------------
# Capa de museos
# --------------------------------
map.add_points(
  museos,
  lon: ->(m) { m["Longitud"].to_f },
  lat: ->(m) { m["Latitud"].to_f },
  icon: "museos.png",            # tu icono
  label: ->(m) { m["nombre"] },
  font: "./fonts/DejaVuSans.ttf",
  size: 11,
  color: [40, 40, 40]
)

# --------------------------------
# Render
# --------------------------------
map.render
map.save("output/museums_parana.png")

puts "Saved output/museums_parana.png"
