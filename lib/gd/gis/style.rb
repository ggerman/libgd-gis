require "yaml"

module GD
  module GIS
    class Style
      attr_reader :roads, :rails, :water, :parks, :points, :order

      def initialize(definition)
        @roads = definition[:roads] || {}
        @rails = definition[:rails] || {}
        @water = definition[:water] || {}
        @parks = definition[:parks] || {}
        @points = definition[:points] || {}
        @order = definition[:order] || []
      end

      def self.load(name, from: "styles")
        path = File.join(from, "#{name}.yml")
        raise "Style not found: #{path}" unless File.exist?(path)

        data = YAML.load_file(path)
        data = deep_symbolize(data)

        new(
          roads: data[:roads],
          rails: data[:rail] || data[:rails],
          water: data[:water],
          parks: data[:park] || data[:parks],
          points: data[:points],
          order: (data[:order] || []).map(&:to_sym)
        )
      end

      def self.deep_symbolize(obj)
        case obj
        when Hash
          obj.transform_keys(&:to_sym)
             .transform_values { |v| deep_symbolize(v) }
        when Array
          obj.map { |v| deep_symbolize(v) }
        else
          obj
        end
      end

      def normalize_color(color)
        case color
        when GD::Color
          color

        when Array
          case color.length
          when 3
            GD::Color.rgb(*color)
          when 4
            GD::Color.rgba(*color)
          else
            raise ArgumentError,
              "Style error: color array must be [r,g,b] or [r,g,b,a]"
          end

        when nil
          GD::GIS::ColorHelpers.random_vivid

        else
          raise ArgumentError,
            "Style error: invalid color format (#{color.inspect})"
        end
      end
    end
  end
end
