# frozen_string_literal: true

module GD
  module GIS
    # Renders collections of line geometries onto a GD image.
    #
    # A LinesLayer draws simple line strings using a fixed stroke
    # color and width. Coordinates are expected to be in
    # [longitude, latitude] order and are projected at render time.
    #
    class LinesLayer
      # @return [Boolean] enables debug rendering
      attr_accessor :debug

      # Creates a new lines layer.
      #
      # @param lines [Array<Array<Array<Float>>>]
      #   array of line strings ([[lng, lat], ...])
      # @param stroke [GD::Color] line color
      # @param width [Integer] stroke width in pixels
      def initialize(lines, stroke:, width:)
        @lines  = lines
        @stroke = stroke
        @width  = width
        @debug  = false
      end

      # Renders the lines onto the given image.
      #
      # @param img [GD::Image] target image
      # @param projection [#call]
      #   callable converting (lng, lat) → (x, y)
      #
      # @raise [RuntimeError] if a line is invalid
      # @return [void]
      def render!(img, projection)
        @lines.each do |line|
          raise "Invalid line: #{line.inspect}" unless valid_line?(line)

          pts = line.map do |lng, lat|
            projection.call(lng, lat)
          end

          color = @debug ? ColorHelpers.random_vivid : @stroke

          pts.each_cons(2) do |a, b|
            img.line(
              a[0], a[1],
              b[0], b[1],
              color,
              thickness: @width
            )
          end
        end
      end

      private

      # Validates a line string.
      #
      # @param line [Object]
      # @return [Boolean]
      def valid_line?(line)
        line.is_a?(Array) &&
          line.size >= 2 &&
          line.first.is_a?(Array) &&
          line.first.size == 2
      end
    end
  end
end
