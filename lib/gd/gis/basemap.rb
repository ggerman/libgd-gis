require "net/http"
require "fileutils"
require "gd"

module GD
  module GIS
    class Basemap
      TILE_SIZE = 256

      attr_reader :origin_x, :origin_y
      attr_reader :kind, :datetime, :resolution

      def initialize(
        zoom,
        bbox,
        provider = :carto_light,
        kind: :cartographic,
        datetime: Time.now,
        resolution: nil
      )
        @zoom = zoom
        @bbox = bbox
        @provider = provider
        @kind = kind
        @datetime = datetime
        @resolution = resolution
      end

      # --------------------------------------------------
      # XYZ providers (UNCHANGED)
      # --------------------------------------------------
      def url(z, x, y, style)
        case style
        when :osm
          "https://tile.openstreetmap.org/#{z}/#{x}/#{y}.png"
        when :carto_light
          "https://a.basemaps.cartocdn.com/light_all/#{z}/#{x}/#{y}.png"
        when :esri_satellite
          "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/#{z}/#{y}/#{x}"
        # ==============================
        # NASA GIBS (tileable, WMTS/XYZ)
        # ==============================

        when :nasa_terra_truecolor
          # Recomendación: 1–2 días atrás para evitar “hoy todavía no está”
          date = (@datetime || (Time.now - 2*86400)).utc.strftime("%Y-%m-%d")
          tms  = "GoogleMapsCompatible_Level9"   # zoom máximo 9 en esta pirámide

          raise "NASA GIBS Terra TrueColor soporta zoom <= 9" if z > 9

          "https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/" \
          "MODIS_Terra_CorrectedReflectance_TrueColor/default/" \
          "#{date}/#{tms}/#{z}/#{y}/#{x}.jpg"

        when :nasa_viirs_truecolor
          date = (@datetime || (Time.now - 2*86400)).utc.strftime("%Y-%m-%d")
          tms  = "GoogleMapsCompatible_Level9"

          raise "NASA GIBS VIIRS TrueColor soporta zoom <= 9" if z > 9

          "https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/" \
          "VIIRS_SNPP_CorrectedReflectance_TrueColor/default/" \
          "#{date}/#{tms}/#{z}/#{y}/#{x}.jpg"

        when :nasa_goes_geocolor
          # GOES en GIBS suele venir como “current” (sin fecha) y zoom más bajo
          tms = "GoogleMapsCompatible_Level6"

          raise "NASA GIBS GOES GeoColor soporta zoom <= 6" if z > 6

          "https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/" \
          "GOES-East_ABI_GeoColor/default/current/" \
          "#{tms}/#{z}/#{y}/#{x}.jpg"
        else
          raise "Unknown XYZ basemap: #{style}"
        end
      end

      # --------------------------------------------------
      # STRATEGY DISPATCH
      # --------------------------------------------------
      def render(map)
        case @provider
        when :goes_full
          render_goes_full(map)
        else
          render_xyz(map)
        end
      end

      # --------------------------------------------------
      # XYZ TILE RENDER (your current behavior)
      # --------------------------------------------------
      def render_xyz(map)
        tiles, x_min, y_min = fetch_tiles

        cols = tiles.map(&:first).max - x_min + 1
        rows = tiles.map { |t| t[1] }.max - y_min + 1

        map.image = GD::Image.new(cols * TILE_SIZE, rows * TILE_SIZE)

        tiles.each do |x, y, file|
          tile = GD::Image.open(file)
          map.image.copy(
            tile,
            (x - x_min) * TILE_SIZE,
            (y - y_min) * TILE_SIZE,
            0, 0, TILE_SIZE, TILE_SIZE
          )
        end
      end

      # --------------------------------------------------
      # GOES FULL-DISK RASTER (THE IMPORTANT PART)
      # --------------------------------------------------
      def render_goes_full(map)
        FileUtils.mkdir_p("tmp/goes")
        path = "tmp/goes/goes_latest.jpg"

        unless File.exist?(path)
          res = http_get_follow(
            URI("https://cdn.star.nesdis.noaa.gov/GOES16/ABI/FD/GEOCOLOR/latest.jpg")
          )
          File.binwrite(path, res.body)
        end

        src = GD::Image.open(path)
        target = map.image

        # copiar píxeles sin blending
        target.alpha_blending = false
        target.save_alpha     = true

        bg =  GD::Color.rgb(0, 0, 0)
        target.filled_rectangle(0, 0, target.width, target.height, bg)

        target.copy_resize(
          src,
          0, 0,                  # destino (arriba a la izquierda)
          0, 0,                  # origen (arriba a la izquierda)
          src.width, src.height, # TODO el source
          target.width, target.height,
          true                   # resample
        )
      end

      # --------------------------------------------------
      # XYZ TILE FETCH (UNCHANGED)
      # --------------------------------------------------
      def lon2tile(lon)
        ((lon + 180.0) / 360.0 * (2**@zoom)).floor
      end

      def lat2tile(lat)
        rad = lat * Math::PI / 180
        ((1 - Math.log(Math.tan(rad) + 1 / Math.cos(rad)) / Math::PI) / 2 * (2**@zoom)).floor
      end

      def fetch_tiles
        west, south, east, north = @bbox

        x_min = lon2tile(west)
        x_max = lon2tile(east)
        y_min = lat2tile(north)
        y_max = lat2tile(south)

        @origin_x = x_min * TILE_SIZE
        @origin_y = y_min * TILE_SIZE

        FileUtils.mkdir_p("tmp/tiles")

        tiles = []

        (x_min..x_max).each do |x|
          (y_min..y_max).each do |y|
            path = "tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.jpg"

            unless File.exist?(path)
              uri = URI(url(@zoom, x, y, @provider))
              Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
                req = Net::HTTP::Get.new(uri)
                req["User-Agent"] = "libgd-gis/0.2"
                res = http.request(req)
                raise "Tile fetch failed #{res.code}" unless res.code == "200"
                File.binwrite(path, res.body)
              end
            end

            tiles << [x, y, path]
          end
        end

        [tiles, x_min, y_min]
      end

      def http_get_follow(uri, limit = 5)
        raise "Too many redirects" if limit == 0

        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          req = Net::HTTP::Get.new(uri)
          req["User-Agent"] = "libgd-gis/0.2"

          res = http.request(req)

          case res
          when Net::HTTPSuccess
            return res
          when Net::HTTPRedirection
            location = res["location"]
            raise "Redirect without location" unless location
            return http_get_follow(URI(location), limit - 1)
          else
            raise "HTTP fetch failed #{res.code}"
          end
        end
      end

      def tileable?
        @provider != :goes_full
      end

    end
  end
end
