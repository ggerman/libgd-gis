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
    end
  end
end
