# tag_water.rb
require "json"

data = JSON.parse(File.read("rios_er.geojson"))

data["features"].each do |f|
  f["properties"] ||= {}
  f["properties"]["layer"] = "water"
end

File.write("rios_water.geojson", JSON.pretty_generate(data))
puts "Generated rios_water.geojson"
