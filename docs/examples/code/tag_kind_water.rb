# tag_kind_water.rb
require "json"

data = JSON.parse(File.read("rios_water.geojson"))

data["features"].each do |f|
  f["properties"] ||= {}
  f["properties"]["kind"] = "water"
end

File.write("rios_kind_water.geojson", JSON.pretty_generate(data))
puts "Generated rios_kind_water.geojson"
