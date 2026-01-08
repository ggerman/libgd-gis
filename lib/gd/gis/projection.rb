module GD
  module GIS
    module Projection
      R = 6378137.0

      def self.mercator_x(lon)
        lon * Math::PI / 180.0 * R
      end

      def self.mercator_y(lat)
        Math.log(Math.tan(Math::PI/4 + lat * Math::PI / 360.0)) * R
      end

      def self.lonlat_to_pixel(lon, lat, min_x, max_x, min_y, max_y, width, height)
        x = mercator_x(lon)
        y = mercator_y(lat)

        px = (x - min_x) / (max_x - min_x) * width
        py = height - (y - min_y) / (max_y - min_y) * height

        [px.to_i, py.to_i]
      end

      TILE_SIZE = 256

      def self.lonlat_to_global_px(lon, lat, zoom)
        lat = [[lat, 85.05112878].min, -85.05112878].max
        n = 2.0 ** zoom

        x = (lon + 180.0) / 360.0 * n * TILE_SIZE

        lat_rad = lat * Math::PI / 180.0
        y = (1.0 - Math.log(Math.tan(lat_rad) + 1.0 / Math.cos(lat_rad)) / Math::PI) / 2.0 * n * TILE_SIZE

        [x, y]
      end
    end
  end
end
