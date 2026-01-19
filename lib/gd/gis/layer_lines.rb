module GD
  module GIS
    class LinesLayer
      attr_accessor :debug

      def initialize(lines, stroke:, width:)
        @lines  = lines
        @stroke = stroke
        @width  = width
        @debug  = false
      end

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

      def valid_line?(line)
        line.is_a?(Array) &&
          line.size >= 2 &&
          line.first.is_a?(Array) &&
          line.first.size == 2
      end
    end
  end
end
