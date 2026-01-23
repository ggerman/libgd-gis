module GD
  module GIS
    class Feature
      attr_reader :geometry, :properties

      def initialize(geometry, properties)
        @geometry   = geometry
        @properties = properties || {}
      end

      # -------------------------------------------------
      # Main draw entry point
      # -------------------------------------------------
      def draw(img, projection, color, width, layer = nil)
        case geometry["type"]
        when "Polygon"
          if layer == :water
            draw_polygon_outline(img, projection, geometry["coordinates"], color, width)
          elsif layer.is_a?(Hash)
            draw_polygon_styled(img, projection, geometry["coordinates"], layer)
          else
            draw_polygon(img, projection, geometry["coordinates"], color)
          end
        when "MultiPolygon"
          geometry["coordinates"].each do |poly|
            if layer == :water
              draw_polygon_outline(img, projection, poly, color, width)
            elsif layer.is_a?(Hash)
              draw_polygon_styled(img, projection, poly, layer)
            else
              draw_polygon(img, projection, poly, color)
            end
          end
        when "LineString", "MultiLineString"
          draw_lines(img, projection, geometry["coordinates"], color, width)
        end
      end

      # -------------------------------------------------
      # Styled polygon rendering (fill + stroke)
      # -------------------------------------------------
      def draw_polygon_styled(img, projection, rings, style)
        fill   = style[:fill]   ? GD::Color.rgb(*style[:fill])   : nil
        stroke = style[:stroke] ? GD::Color.rgb(*style[:stroke]) : nil

        rings.each do |ring|
          pts = ring.map do |lon,lat|
            x,y = projection.call(lon,lat)
            next if x.nil? || y.nil?
            [x.to_i, y.to_i]
          end.compact

          pts = pts.chunk_while { |a,b| a == b }.map(&:first)
          next if pts.length < 3

          img.filled_polygon(pts, fill) if fill

          if stroke
            pts.each_cons(2) { |a,b| img.line(a[0],a[1], b[0],b[1], stroke) }
            img.line(pts.last[0], pts.last[1], pts.first[0], pts.first[1], stroke)
          end
        end
      end

      # -------------------------------------------------
      # Polygon outline (used for water)
      # -------------------------------------------------
      def draw_polygon_outline(img, projection, rings, color, width)
        return if color.nil?

        rings.each do |ring|
          pts = ring.map do |lon, lat|
            x, y = projection.call(lon, lat)
            [x.to_i, y.to_i] if x && y
          end.compact

          next if pts.size < 2

          img.lines(pts, color, width)
        end
      end

      # -------------------------------------------------
      # Legacy filled polygon (single color)
      # -------------------------------------------------
      def draw_polygon(img, projection, rings, color)
        return if color.nil?

        rings.each do |ring|
          pts = ring.map do |lon,lat|
            x,y = projection.call(lon,lat)
            next if x.nil? || y.nil?
            [x.to_i, y.to_i]
          end.compact

          pts = pts.chunk_while { |a,b| a == b }.map(&:first)
          next if pts.length < 3

          img.filled_polygon(pts, color)
        end
      end

      # -------------------------------------------------
      # Lines
      # -------------------------------------------------
      def draw_lines(img, projection, coords, color, width)
        return if color.nil?

        if coords.first.is_a?(Array) && coords.first.first.is_a?(Array)
          coords.each { |line| draw_line(img, projection, line, color, width) }
        else
          draw_line(img, projection, coords, color, width)
        end
      end

      def draw_line(img, projection, coords, color, width)
        return if color.nil?

        coords.each_cons(2) do |(lon1,lat1),(lon2,lat2)|
          x1,y1 = projection.call(lon1,lat1)
          x2,y2 = projection.call(lon2,lat2)
          img.line(x1, y1, x2, y2, color, thickness: width)
        end
      end

      # -------------------------------------------------
      # Metadata helpers
      # -------------------------------------------------
      def label
        properties["name:ja"] || properties["name"]
      end

      def centroid
        pts = []

        case geometry["type"]
        when "LineString"
          pts = geometry["coordinates"]
        when "MultiLineString"
          pts = geometry["coordinates"].flatten(1)
        end

        return nil if pts.empty?

        lon = pts.map(&:first).sum / pts.size
        lat = pts.map(&:last).sum / pts.size

        [lon, lat]
      end
    end
  end
end
