module GD
  module GIS
    class PolygonsLayer
      attr_accessor :debug

      def initialize(polygons, fill:, stroke: nil, width: nil)
        @polygons = polygons
        @fill = fill
        @stroke = stroke
        @width = width

	@debug = false
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
        @polygons.each do |polygon|
          # polygon = [ ring, ring, ... ]
          polygon.each_with_index do |ring, idx|
            pts = ring.map do |lng, lat|
              projection.call(lng, lat)
            end

            @stroke = GD::GIS::ColorHelpers.random_vivid if @debug
            @fill   = GD::GIS::ColorHelpers.random_vivid if @debug

            if idx == 0
              # ring exterior
              img.filled_polygon(pts, @fill)
            end

            if @stroke
              pts.each_cons(2) do |a, b|
                img.line(a[0], a[1], b[0], b[1], @stroke, thickness: (@width || 1))
              end
            end
          end
        end
      end

    end
  end
end
