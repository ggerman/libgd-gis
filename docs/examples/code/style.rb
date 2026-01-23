require "yaml"

module GD
  module GIS
    class Style
      attr_reader :roads, :rails, :water, :parks, :order

      def initialize(definition)
        @roads = definition[:roads] || {}
        @rails = definition[:rails] || {}
        @water = definition[:water] || {}
        @parks = definition[:parks] || {}
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
    end
  end
end
