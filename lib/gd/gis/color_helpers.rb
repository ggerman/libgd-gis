# frozen_string_literal: true

module GD
  module GIS
    # Utility helpers for generating colors compatible with GD.
    #
    # This module provides convenience methods for creating
    # random RGB / RGBA colors and vivid colors suitable for
    # map rendering and styling.
    #
    # All methods return instances of {GD::Color}.
    #
    module ColorHelpers
      # Generates a random RGB color.
      #
      # @param min [Integer] minimum channel value (0–255)
      # @param max [Integer] maximum channel value (0–255)
      # @return [GD::Color]
      def self.random_rgb(min: 0, max: 255)
        GD::Color.rgb(
          rand(min..max),
          rand(min..max),
          rand(min..max)
        )
      end

      # Generates a random RGBA color.
      #
      # @param min [Integer] minimum channel value (0–255)
      # @param max [Integer] maximum channel value (0–255)
      # @param alpha [Integer, nil] alpha channel (0–255), random if nil
      # @return [GD::Color]
      def self.random_rgba(min: 0, max: 255, alpha: nil)
        GD::Color.rgba(
          rand(min..max),
          rand(min..max),
          rand(min..max),
          alpha || rand(50..255)
        )
      end

      # Generates a random vivid RGB color.
      #
      # Vivid colors avoid low saturation and brightness values,
      # making them suitable for distinguishing map features.
      #
      # @return [GD::Color]
      def self.random_vivid
        h = rand
        s = rand(0.6..1.0)
        v = rand(0.7..1.0)

        r, g, b = hsv_to_rgb(h, s, v)
        GD::Color.rgb(r, g, b)
      end

      # Converts HSV color values to RGB.
      #
      # Hue, saturation, and value are expected to be in the
      # range 0.0–1.0.
      #
      # @param h [Float] hue
      # @param s [Float] saturation
      # @param v [Float] value
      # @return [Array<Integer>] RGB values in the range 0–255
      def self.hsv_to_rgb(h, s, v)
        i = (h * 6).floor
        f = (h * 6) - i
        p = v * (1 - s)
        q = v * (1 - (f * s))
        t = v * (1 - ((1 - f) * s))

        r, g, b =
          case i % 6
          when 0 then [v, t, p]
          when 1 then [q, v, p]
          when 2 then [p, v, t]
          when 3 then [p, q, v]
          when 4 then [t, p, v]
          when 5 then [v, p, q]
          end

        [(r * 255).to_i, (g * 255).to_i, (b * 255).to_i]
      end
    end
  end
end
