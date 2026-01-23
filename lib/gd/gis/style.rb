# frozen_string_literal: true

require "yaml"

module GD
  module GIS
    # Defines visual styling rules for map rendering.
    #
    # A Style object encapsulates all visual configuration used
    # during rendering, including colors, stroke widths, fonts,
    # and layer ordering.
    #
    # Styles are typically loaded from YAML files and applied
    # to a {GD::GIS::Map} instance before rendering.
    #
    class Style
      # @return [Hash] road styling rules
      attr_reader :roads

      # @return [Hash] rail styling rules
      attr_reader :rails

      # @return [Hash] water styling rules
      attr_reader :water

      # @return [Hash] park styling rules
      attr_reader :parks

      # @return [Hash] point styling rules
      attr_reader :points

      # @return [Array<Symbol>] drawing order of semantic layers
      attr_reader :order

      # Creates a new style from a definition hash.
      #
      # @param definition [Hash]
      #   style definition with optional sections:
      #   :roads, :rails, :water, :parks, :points, :order
      def initialize(definition)
        @roads = definition[:roads] || {}
        @rails = definition[:rails] || {}
        @water = definition[:water] || {}
        @parks = definition[:parks] || {}
        @points = definition[:points] || {}
        @order = definition[:order] || []
      end

      # Loads a style definition from a YAML file.
      #
      # The file name is resolved as:
      #
      #   <from>/<name>.yml
      #
      # All keys are deep-symbolized on load.
      #
      # @param name [String, Symbol]
      #   style name (without extension)
      # @param from [String]
      #   directory containing style files
      #
      # @return [Style]
      # @raise [RuntimeError] if the style file does not exist
      # @raise [Psych::SyntaxError] if the YAML is invalid
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

      # Recursively converts hash keys to symbols.
      #
      # @param obj [Object]
      # @return [Object]
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

      # Normalizes a color definition into a GD::Color.
      #
      # Accepted formats:
      # - GD::Color instance
      # - [r, g, b]
      # - [r, g, b, a]
      # - nil (generates a random vivid color)
      #
      # @param color [GD::Color, Array<Integer>, nil]
      # @return [GD::Color]
      # @raise [ArgumentError] if the format is invalid
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
