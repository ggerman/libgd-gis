# frozen_string_literal: true

module GD
  module GIS
    # Represents a single geographic feature with geometry and properties.
    #
    # A Feature acts as the rendering bridge between:
    # - GeoJSON-like geometry data
    # - Attribute properties
    # - GD drawing primitives
    #
    # Features are responsible for drawing themselves onto a GD image
    # using a provided projection and styling information.
    #
    class Feature
      # @return [Hash] GeoJSON geometry object
      attr_reader :geometry

      # @return [Hash] feature properties (tags)
      attr_reader :properties

      # @return [Symbol, nil] logical layer identifier
      attr_reader :layer

      # Creates a new feature.
      #
      # @param geometry [Hash]
      #   GeoJSON-like geometry hash (type + coordinates)
      # @param properties [Hash, nil]
      #   feature attributes / tags
      # @param layer [Symbol, nil]
      #   optional logical layer identifier
      def initialize(geometry, properties, layer = nil)
        @geometry   = geometry
        @properties = properties || {}
        @layer      = layer
      end

      # Draws the feature onto a GD image.
      #
      # This is the main rendering entry point and dispatches
      # to the appropriate drawing method based on geometry type
      # and layer styling.
      #
      # Supported geometry types:
      # - Polygon
      # - MultiPolygon
      # - LineString
      # - MultiLineString
      #
      # @param img [GD::Image] target image
      # @param projection [#call]
      #   callable object converting (lon, lat) → (x, y)
      # @param color [GD::Color, nil] base color
      # @param width [Integer] stroke width
      # @param layer [Symbol, Hash, nil]
      #   layer identifier or style hash
      #
      # @return [void]
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

      # Draws a polygon with fill and stroke styling.
      #
      # @param img [GD::Image]
      # @param projection [#call]
      # @param rings [Array]
      #   polygon rings (GeoJSON format)
      # @param style [Hash]
      #   style hash with :fill and/or :stroke RGB arrays
      #
      # @return [void]
      def draw_polygon_styled(img, projection, rings, style)
        fill   = style[:fill]   ? GD::Color.rgb(*style[:fill])   : nil
        stroke = style[:stroke] ? GD::Color.rgb(*style[:stroke]) : nil

        rings.each do |ring|
          pts = ring.filter_map do |lon, lat|
            x, y = projection.call(lon, lat)
            next if x.nil? || y.nil?

            [x.to_i, y.to_i]
          end

          pts = pts.chunk_while { |a, b| a == b }.map(&:first)
          next if pts.length < 3

          img.filled_polygon(pts, fill) if fill

          if stroke
            pts.each_cons(2) { |a, b| img.line(a[0], a[1], b[0], b[1], stroke) }
            img.line(pts.last[0], pts.last[1], pts.first[0], pts.first[1], stroke)
          end
        end
      end

      # Draws only the outline of a polygon.
      #
      # Used primarily for water bodies.
      #
      # @param img [GD::Image]
      # @param projection [#call]
      # @param rings [Array]
      # @param color [GD::Color]
      # @param width [Integer]
      # @return [void]
      def draw_polygon_outline(img, projection, rings, color, width)
        return if color.nil?

        rings.each do |ring|
          pts = ring.filter_map do |lon, lat|
            x, y = projection.call(lon, lat)
            [x.to_i, y.to_i] if x && y
          end

          next if pts.size < 2

          img.lines(pts, color, width)
        end
      end

      # Draws a filled polygon using a single color.
      #
      # @param img [GD::Image]
      # @param projection [#call]
      # @param rings [Array]
      # @param color [GD::Color]
      # @return [void]
      def draw_polygon(img, projection, rings, color)
        return if color.nil?

        rings.each do |ring|
          pts = ring.filter_map do |lon, lat|
            x, y = projection.call(lon, lat)
            next if x.nil? || y.nil?

            [x.to_i, y.to_i]
          end

          pts = pts.chunk_while { |a, b| a == b }.map(&:first)
          next if pts.length < 3

          img.filled_polygon(pts, color)
        end
      end

      # Draws line or multiline geometries.
      #
      # @param img [GD::Image]
      # @param projection [#call]
      # @param coords [Array]
      # @param color [GD::Color]
      # @param width [Integer]
      # @return [void]
      def draw_lines(img, projection, coords, color, width)
        return if color.nil?

        if coords.first.is_a?(Array) && coords.first.first.is_a?(Array)
          coords.each { |line| draw_line(img, projection, line, color, width) }
        else
          draw_line(img, projection, coords, color, width)
        end
      end

      # Draws a single line geometry.
      #
      # @param img [GD::Image]
      # @param projection [#call]
      # @param coords [Array]
      # @param color [GD::Color]
      # @param width [Integer]
      # @return [void]
      def draw_line(img, projection, coords, color, width)
        return if color.nil?

        coords.each_cons(2) do |(lon1, lat1), (lon2, lat2)|
          x1, y1 = projection.call(lon1, lat1)
          x2, y2 = projection.call(lon2, lat2)
          img.line(x1, y1, x2, y2, color, thickness: width)
        end
      end

      # Returns the display label for the feature.
      #
      # Prefers Japanese names if present.
      #
      # @return [String, nil]
      def label
        properties["name:ja"] || properties["name"]
      end

      # Computes a simple centroid for line-based geometries.
      #
      # @return [Array<Float>, nil] [lon, lat] or nil
      def centroid
        pts = []

        case geometry["type"]
        when "LineString"
          pts = geometry["coordinates"]
        when "MultiLineString"
          pts = geometry["coordinates"].flatten(1)
        end

        return nil if pts.empty?

        lon = pts.sum(&:first) / pts.size
        lat = pts.sum(&:last) / pts.size

        [lon, lat]
      end
    end
  end
end
