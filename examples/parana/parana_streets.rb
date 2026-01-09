require "csv"
require "gd/gis"

PARANA = [-60.56, -31.76, -60.50, -31.71]

map = GD::GIS::Map.new(
  bbox: PARANA,
  zoom: 15,
  basemap: :carto_light
)

map.add_geojson(
  "parana_streets.geojson",
  color: [250,0,0]
)

# Museos desde tu CSV
museos = CSV.read("museums.csv", headers: true)

PARANA = [-60.56, -31.76, -60.50, -31.71]

museos = CSV.read("museums.csv", headers: true)

en_bbox = museos.select do |r|
  lon = r["Longitud"].to_f
  lat = r["Latitud"].to_f

  lon >= PARANA[0] && lon <= PARANA[2] &&
  lat >= PARANA[1] && lat <= PARANA[3]
end

puts "Museos en bbox: #{en_bbox.size}"
puts en_bbox.first(10).map { |r| "#{r['nombre']} (#{r['Latitud']}, #{r['Longitud']})" }

map.add_points(
  museos,
  lon: ->(r) { r["Longitud"].to_f },
  lat: ->(r) { r["Latitud"].to_f },
  icon: "museum.png",
  label: ->(r) { r["nombre"] },
  font: "./fonts/DejaVuSans.ttf",
  size: 12,
  color: [40,40,40]
)

map.render
map.save("parana.png")

