module GD
  module GIS
    module Geometry
      def self.buffer_line(coords, meters)
        left = []
        right = []

        coords.each_cons(2) do |a,b|
          x1,y1 = a
          x2,y2 = b

          dx = x2 - x1
          dy = y2 - y1

          len = Math.sqrt(dx*dx + dy*dy)
          next if len == 0

          # normal vector
          nx = -dy / len
          ny = dx / len

          # offset in degrees (approx)
          # 1 meter ≈ 1 / 111_320 degrees
          off = meters / 111_320.0

          left  << [x1 + nx*off, y1 + ny*off]
          right << [x1 - nx*off, y1 - ny*off]
        end

        # add last point
        x2,y2 = coords.last
        left  << [x2, y2]
        right << [x2, y2]

        polygon = left + right.reverse
        polygon
      end
    end
  end
end
