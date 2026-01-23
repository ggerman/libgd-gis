# tag_type_water.rb
require "json"

data = JSON.parse(File.read("rios_er.geojson"))

data["features"].each do |f|
  f["properties"] ||= {}
  f["properties"]["type"] = "water"
end

File.write("rios_type_water.geojson", JSON.pretty_generate(data))
puts "Generated rios_type_water.geojson"
