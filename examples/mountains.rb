require "net/http"
require "uri"
require "fileutils"
require "json"
require "gd"

ZOOM = 4
TILE_SIZE = 256

X_MIN = 0
Y_MIN = 0
X_MAX = (2 ** ZOOM) - 1
Y_MAX = (2 ** ZOOM) - 1

COLS = X_MAX - X_MIN + 1
ROWS = Y_MAX - Y_MIN + 1

WIDTH  = COLS * TILE_SIZE
HEIGHT = ROWS * TILE_SIZE

FONT = "./fonts/DejaVuSans-Bold.ttf"

FileUtils.mkdir_p("tmp/tiles")
FileUtils.mkdir_p("output")

def lon2px(lon, z)
  ((lon + 180.0) / 360.0 * (256 * 2**z))
end

def lat2px(lat, z)
  rad = lat * Math::PI / 180
  ((1 - Math.log(Math.tan(rad) + 1 / Math.cos(rad)) / Math::PI) / 2 * (256 * 2**z))
end

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

puts "Building world map #{WIDTH}x#{HEIGHT}..."

map = GD::Image.new(WIDTH, HEIGHT)

(X_MIN..X_MAX).each_with_index do |x, cx|
  (Y_MIN..Y_MAX).each_with_index do |y, cy|
    tile = GD::Image.open(fetch_tile(ZOOM, x, y))
    map.copy(tile, cx * TILE_SIZE, cy * TILE_SIZE, 0, 0, TILE_SIZE, TILE_SIZE)
  end
end

peaks = JSON.parse(File.read("picks.json"))

red   = GD::Color.rgb(220, 40, 40)
black = GD::Color.rgb(0, 0, 0)

puts "Plotting peaks..."

peaks.each do |p|
  lon  = p["longitude"]
  lat  = p["latitude"]
  name = p["name"]

  px = lon2px(lon, ZOOM)
  py = lat2px(lat, ZOOM)

  x = px.to_i
  y = py.to_i

  map.filled_circle(x, y, 7, red)

  map.text(
    name,
    x: x + 10,
    y: y - 5,
    size: 10,
    color: black,
    font: FONT
  )
end

# =========================
# Save
# =========================
map.save("output/world_peaks.png")
puts "Saved output/world_peaks.png"
