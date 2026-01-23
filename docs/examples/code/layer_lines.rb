module GD
  module GIS
    class LinesLayer
      def initialize(features, stroke:, width:)
        @features = features
        @stroke = stroke
        @width = width
      end

      def render!(img, projection)
        @features.each do |f|
          geom = f["geometry"]

          case geom["type"]
          when "LineString"
            draw_line(geom["coordinates"], img, projection)
          when "MultiLineString"
            geom["coordinates"].each do |line|
              draw_line(line, img, projection)
            end
          end
        end
      end

      def draw_line(coords, img, projection)
        pts = coords.map { |p| projection.call(p[0], p[1]) }

        (0...pts.size-1).each do |i|
          x1,y1 = pts[i]
          x2,y2 = pts[i+1]
          img.line(x1,y1,x2,y2,@stroke, thickness: @width)
        end
      end
    end
  end
end
