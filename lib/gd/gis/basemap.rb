require "net/http"
require "fileutils"

module GD
  module GIS
    class Basemap
      TILE_SIZE = 256

      def initialize(zoom, bbox, provider=:carto_light)
        @zoom = zoom
        @bbox = bbox
        @provider = provider
      end

      def url(z,x,y)
        "https://tile.openstreetmap.org/#{z}/#{x}/#{y}.png"
      end

      def lon2tile(lon)
        ((lon + 180.0) / 360.0 * (2 ** @zoom)).floor
      end

      def lat2tile(lat)
        rad = lat * Math::PI / 180
        ((1 - Math.log(Math.tan(rad) + 1 / Math.cos(rad)) / Math::PI) / 2 * (2 ** @zoom)).floor
      end

      def fetch_tiles
        west, south, east, north = @bbox

        x_min = lon2tile(west)
        x_max = lon2tile(east)
        y_min = lat2tile(north)
        y_max = lat2tile(south)

        @x_min = x_min
        @y_min = y_min

        FileUtils.mkdir_p("tmp/tiles")

        tiles = []

        (x_min..x_max).each do |x|
          (y_min..y_max).each do |y|
            path = "tmp/tiles/#{@zoom}_#{x}_#{y}.png"
            unless File.exist?(path)
              uri = URI(url(@zoom,x,y))

              Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
                req = Net::HTTP::Get.new(uri)
                req["User-Agent"] = "libgd-gis/0.1 (Ruby)"

                res = http.request(req)

                unless res.code == "200"
                  raise "Tile fetch failed #{res.code}"
                end

                File.binwrite(path, res.body)
              end

            end
            tiles << [x,y,path]
          end
        end

        [tiles, x_min, y_min]
      end
    end
  end
end
