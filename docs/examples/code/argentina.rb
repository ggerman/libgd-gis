require "net/http"
require "uri"
require "fileutils"
require "gd"

ZOOM = 7
TILE_SIZE = 256

# Argentina bounding box (WGS84)
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

# Compute tile range for Argentina
x_min = lon2tile(WEST,  ZOOM)
x_max = lon2tile(EAST,  ZOOM)
y_min = lat2tile(NORTH, ZOOM)
y_max = lat2tile(SOUTH, ZOOM)

puts "Argentina tiles at z=#{ZOOM}:"
puts "x: #{x_min} .. #{x_max}"
puts "y: #{y_min} .. #{y_max}"

COLS = x_max - x_min + 1
ROWS = y_max - y_min + 1

WIDTH  = COLS * TILE_SIZE
HEIGHT = ROWS * TILE_SIZE

FileUtils.mkdir_p("tmp/tiles")
FileUtils.mkdir_p("output")

def fetch_tile(z, x, y)
  path = "tmp/tiles/#{z}_#{x}_#{y}.png"
  return path if File.exist?(path)

  url = URI("https://basemaps.cartocdn.com/light_all/#{z}/#{x}/#{y}.png")
  puts "Downloading #{url}"

  Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
    req = Net::HTTP::Get.new(url)
    req["User-Agent"] = "ruby-libgd-gis"
    res = http.request(req)
    raise "Tile failed #{z}/#{x}/#{y}" unless res.code == "200"
    File.binwrite(path, res.body)
  end

  path
end

puts "Downloading tiles..."

(x_min..x_max).each do |x|
  (y_min..y_max).each do |y|
    fetch_tile(ZOOM, x, y)
  end
end

puts "Composing map..."

map = GD::Image.new(WIDTH, HEIGHT)

(x_min..x_max).each_with_index do |x, cx|
  (y_min..y_max).each_with_index do |y, cy|
    tile = GD::Image.open("tmp/tiles/#{ZOOM}_#{x}_#{y}.png")
    map.copy(tile, cx * TILE_SIZE, cy * TILE_SIZE, 0, 0, TILE_SIZE, TILE_SIZE)
  end
end

map.save("output/argentina.png")

puts "Saved output/argentina.png"
