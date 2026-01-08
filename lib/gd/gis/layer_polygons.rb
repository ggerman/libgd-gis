module GD
  module GIS
    class PolygonsLayer
      def initialize(polygons, fill:, stroke: nil, width: nil)
        @polygons = polygons
        @fill = fill
        @stroke = stroke
        @width = width
      end

      def self.from_lines(features, stroke:, fill:, width:)
        polys = []

        features.each do |f|
          coords = f["geometry"]["coordinates"]
          poly = Geometry.buffer_line(coords, width)
          polys << poly
        end

        new(polys, fill: fill, stroke: stroke)
      end

      def render!(img, projection)
        @polygons.each do |poly|
          pts = poly.map { |p| projection.call(p[0], p[1]) }

          img.filled_polygon(pts, @fill)

          if @stroke
            pts.each_cons(2) do |a,b|
              img.line(a[0],a[1],b[0],b[1],@stroke, thickness: 1)
            end
          end
        end
      end
    end
  end
end
