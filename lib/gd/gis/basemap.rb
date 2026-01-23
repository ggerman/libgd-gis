# frozen_string_literal: true

require "net/http"
require "fileutils"

module GD
  module GIS
    # Fetches and manages raster basemap tiles using the XYZ
    # Web Mercator tiling scheme.
    #
    # A Basemap is responsible for:
    # - Converting geographic coordinates to tile coordinates
    # - Downloading raster tiles from public tile providers
    # - Caching tiles on disk
    # - Exposing pixel origins for map composition
    #
    # All tiles are assumed to be 256×256 pixels.
    #
    # @example Fetch tiles for a bounding box
    #   bbox = [-3.8, 40.3, -3.6, 40.5] # west, south, east, north
    #   basemap = GD::GIS::Basemap.new(12, bbox, :carto_light)
    #   tiles, origin_x, origin_y = basemap.fetch_tiles
    #
    class Basemap
      # Tile size in pixels (Web Mercator standard)
      TILE_SIZE = 256

      # @return [Integer] pixel X origin of the basemap
      attr_reader :origin_x

      # @return [Integer] pixel Y origin of the basemap
      attr_reader :origin_y

      # Creates a new basemap tile source.
      #
      # @param zoom [Integer] zoom level
      # @param bbox [Array<Float>] bounding box [west, south, east, north]
      # @param provider [Symbol] tile provider/style
      def initialize(zoom, bbox, provider = :carto_light)
        @zoom = zoom
        @bbox = bbox
        @provider = provider
      end

      # Builds a tile URL for a given provider and tile coordinate.
      #
      # @param z [Integer] zoom level
      # @param x [Integer] tile X coordinate
      # @param y [Integer] tile Y coordinate
      # @param style [Symbol] tile style/provider
      # @return [String] tile URL
      # @raise [RuntimeError] if the provider is unknown
      def url(z, x, y, style = :osm)
        case style

        # ==============================
        # OpenStreetMap
        # ==============================
        when :osm
          "https://tile.openstreetmap.org/#{z}/#{x}/#{y}.png"

        when :osm_hot
          "https://tile.openstreetmap.fr/hot/#{z}/#{x}/#{y}.png"

        when :osm_fr
          "https://a.tile.openstreetmap.fr/osmfr/#{z}/#{x}/#{y}.png"

        # ==============================
        # CARTO
        # ==============================
        when :carto_light
          "https://a.basemaps.cartocdn.com/light_all/#{z}/#{x}/#{y}.png"

        when :carto_light_nolabels
          "https://a.basemaps.cartocdn.com/light_nolabels/#{z}/#{x}/#{y}.png"

        when :carto_dark
          "https://a.basemaps.cartocdn.com/dark_all/#{z}/#{x}/#{y}.png"

        when :carto_dark_nolabels
          "https://a.basemaps.cartocdn.com/dark_nolabels/#{z}/#{x}/#{y}.png"

        # ==============================
        # ESRI / ArcGIS (Satellite, terrain, hybrid)
        # ==============================
        when :esri_satellite
          "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/#{z}/#{y}/#{x}"

        when :esri_streets
          "https://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/#{z}/#{y}/#{x}"

        when :esri_terrain
          "https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/#{z}/#{y}/#{x}"

        # ==============================
        # STAMEN 503
        # ==============================
        when :stamen_toner
          "https://stamen-tiles.a.ssl.fastly.net/toner/#{z}/#{x}/#{y}.png"

        when :stamen_toner_lite
          "https://stamen-tiles.a.ssl.fastly.net/toner-lite/#{z}/#{x}/#{y}.png"

        when :stamen_terrain
          "https://stamen-tiles.a.ssl.fastly.net/terrain/#{z}/#{x}/#{y}.png"

        when :stamen_watercolor
          "https://stamen-tiles.a.ssl.fastly.net/watercolor/#{z}/#{x}/#{y}.jpg"

        # ==============================
        # OpenTopoMap
        # ==============================
        when :topo
          "https://a.tile.opentopomap.org/#{z}/#{x}/#{y}.png"

        # ==============================
        # Wikimedia 403
        # ==============================
        when :wikimedia
          "https://maps.wikimedia.org/osm-intl/#{z}/#{x}/#{y}.png"

        # ==============================
        # OpenRailwayMap
        # ==============================
        when :railway
          "https://tiles.openrailwaymap.org/standard/#{z}/#{x}/#{y}.png"

        # ==============================
        # CyclOSM
        # ==============================
        when :cyclosm
          "https://a.tile-cyclosm.openstreetmap.fr/cyclosm/#{z}/#{x}/#{y}.png"

        else
          raise "Unknown basemap style: #{style}"
        end
      end

      # Converts longitude to tile X coordinate.
      #
      # @param lon [Float] longitude in degrees
      # @return [Integer] tile X coordinate
      def lon2tile(lon)
        ((lon + 180.0) / 360.0 * (2**@zoom)).floor
      end

      # Converts latitude to tile Y coordinate.
      #
      # @param lat [Float] latitude in degrees
      # @return [Integer] tile Y coordinate
      def lat2tile(lat)
        rad = lat * Math::PI / 180
        ((1 - (Math.log(Math.tan(rad) + (1 / Math.cos(rad))) / Math::PI)) / 2 * (2**@zoom)).floor
      end

      # Downloads all tiles required to cover the bounding box.
      #
      # Tiles are cached on disk under `tmp/tiles`.
      #
      # @return [Array]
      #   - tiles [Array<Array(Integer, Integer, String)>]
      #     list of [x, y, file_path]
      #   - origin_x [Integer] pixel X origin
      #   - origin_y [Integer] pixel Y origin
      #
      # @raise [RuntimeError] if a tile cannot be fetched
      def fetch_tiles
        west, south, east, north = @bbox

        x_min = lon2tile(west)
        x_max = lon2tile(east)
        y_min = lat2tile(north)
        y_max = lat2tile(south)

        @x_min = x_min
        @y_min = y_min

        @origin_x = x_min * TILE_SIZE
        @origin_y = y_min * TILE_SIZE

        FileUtils.mkdir_p("tmp/tiles")

        tiles = []

        (x_min..x_max).each do |x|
          (y_min..y_max).each do |y|
            path = nil

            if File.exist?("tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.png") ||
               File.exist?("tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.jpg")
              path = if File.exist?("tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.png")
                       "tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.png"
                     else
                       "tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.jpg"
                     end
            else

              uri = URI(url(@zoom, x, y, @provider))

              Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
                req = Net::HTTP::Get.new(uri)
                req["User-Agent"] = "libgd-gis/0.1 (Ruby)"

                res = http.request(req)
                raise "Tile fetch failed #{res.code}" unless res.code == "200"

                content_type = res["content-type"]

                ext =
                  if content_type&.include?("png")
                    "png"
                  elsif content_type&.include?("jpeg") || content_type&.include?("jpg")
                    "jpg"
                  else
                    raise "Unsupported tile type: #{content_type}"
                  end

                path = "tmp/tiles/#{@provider}_#{@zoom}_#{x}_#{y}.#{ext}"
                File.binwrite(path, res.body)
              end
            end

            tiles << [x, y, path]
          end
        end

        [tiles, x_min, y_min]
      end
    end
  end
end
