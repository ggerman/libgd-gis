module GD
  module GIS
    class PointsLayer
      def initialize(data, lon:, lat:, icon:)
        @data = data
        @lon = lon
        @lat = lat
        @icon = GD::Image.open(icon)
      end

      def render!(img, projection)
        w = @icon.width
        h = @icon.height

        @data.each do |row|
          lon = @lon.call(row)
          lat = @lat.call(row)

          x,y = projection.call(lon,lat)
          img.copy(@icon, x - w/2, y - h/2, 0,0,w,h)
        end
      end
    end
  end
end
