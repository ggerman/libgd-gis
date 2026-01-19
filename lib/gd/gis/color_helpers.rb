module GD
  module GIS
    module ColorHelpers
      # --------------------------------------------------
      # Random RGB color
      # --------------------------------------------------
      def self.random_rgb(min: 0, max: 255)
        GD::Color.rgb(
          rand(min..max),
          rand(min..max),
          rand(min..max)
        )
      end

      # --------------------------------------------------
      # Random RGBA color
      # --------------------------------------------------
      def self.random_rgba(min: 0, max: 255, alpha: nil)
        GD::Color.rgba(
          rand(min..max),
          rand(min..max),
          rand(min..max),
          alpha || rand(50..255)
        )
      end

      # --------------------------------------------------
      # Random vivid color (avoid gray/mud)
      # --------------------------------------------------
      def self.random_vivid
        h = rand
        s = rand(0.6..1.0)
        v = rand(0.7..1.0)

        r, g, b = hsv_to_rgb(h, s, v)
        GD::Color.rgb(r, g, b)
      end

      # --------------------------------------------------
      # HSV → RGB
      # --------------------------------------------------
      def self.hsv_to_rgb(h, s, v)
        i = (h * 6).floor
        f = h * 6 - i
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)

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

