require "gd"
require_relative "basemap"
require_relative "projection"
require_relative "geometry"
require_relative "layer_points"
require_relative "layer_lines"
require_relative "layer_polygons"
require_relative "layer_geojson"

module GD
  module GIS
    class Map
      TILE_SIZE = 256

      def initialize(bbox:, zoom:, basemap:)
        @bbox   = bbox
        @zoom   = zoom
        @basemap = Basemap.new(zoom, bbox, basemap)
        @layers = []
      end

      # ------------------------------
      # Layer DSL
      # ------------------------------

      def add_points(data, lon:, lat:, icon: nil, label: nil, font: nil, size: 12, color: [0,0,0])
        @layers << PointsLayer.new(
          data,
          lon: lon,
          lat: lat,
          icon: icon,
          label: label,
          font: font,
          size: size,
          color: color
        )
      end

      def add_lines(features, stroke:, width:)
        @layers << LinesLayer.new(features, stroke: stroke, width: width)
      end

      def add_polygons(polygons, fill:, stroke: nil, width: nil)
        @layers << PolygonsLayer.new(polygons, fill: fill, stroke: stroke, width: width)
      end

      def add_geojson(path, **options)
        @layers << LayerGeoJSON.new(path, options)
      end

      # ------------------------------
      # Rendering
      # ------------------------------

      def render(path = "map.png")
        tiles, x_min, y_min = @basemap.fetch_tiles

        xs = tiles.map { |t| t[0] }
        ys = tiles.map { |t| t[1] }

        cols = xs.max - xs.min + 1
        rows = ys.max - ys.min + 1

        width  = cols * TILE_SIZE
        height = rows * TILE_SIZE

        origin_x = x_min * TILE_SIZE
        origin_y = y_min * TILE_SIZE

        @img = GD::Image.new(width, height)
        @img.alpha_blending = true
        @img.save_alpha = true

        # Draw basemap
        tiles.each do |x, y, file|
          tile = GD::Image.open(file)
          cx = x - x_min
          cy = y - y_min
          @img.copy(tile, cx * TILE_SIZE, cy * TILE_SIZE, 0, 0, TILE_SIZE, TILE_SIZE)
        end

        # WebMercator projection → local pixels
        scale = TILE_SIZE * (2 ** @zoom)

        projection = lambda do |lon, lat|
          x = (lon + 180.0) / 360.0 * scale

          lat_rad = lat * Math::PI / 180.0
          y = (1.0 - Math.log(Math.tan(lat_rad) + 1.0 / Math.cos(lat_rad)) / Math::PI) / 2.0 * scale

          [
            (x - origin_x).round,
            (y - origin_y).round
          ]
        end

        # Draw layers
        @layers.each do |layer|
          layer.render!(@img, projection)
        end
      end

      def save(path)
        @img.save(path)
      end
    end
  end
end
