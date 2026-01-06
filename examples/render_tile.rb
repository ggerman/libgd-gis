require "net/http"
require "fileutils"
require_relative "../lib/libgd_gis"

def render
  tmp = Tempfile.new(["tile", ".png"])
  tmp.binmode

  uri = URI(@source)
  req = Net::HTTP::Get.new(uri)
  req["User-Agent"] = "ruby-libgd-gis/0.1 (https://github.com/ggerman/ruby-libgd-gis)"

  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    http.request(req) do |res|
      res.read_body { |chunk| tmp.write(chunk) }
    end
  end

  tmp.flush
  @image = GD::Image.open(tmp.path)
ensure
  tmp.close
end

FileUtils.mkdir_p("output")

tile = LibGD::GIS::Tile.osm(z: 4, x: 8, y: 5)
tile.render
tile.save("output/tile.png")

puts "Tile written to output/tile.png"
