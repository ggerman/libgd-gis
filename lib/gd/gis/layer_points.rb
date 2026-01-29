# frozen_string_literal: true

module GD
  module GIS
    # Renders point data as icons (markers) with optional labels.
    #
    # A PointsLayer draws markers for arbitrary data records.
    # Longitude and latitude values are extracted using callables,
    # allowing the layer to work with any data structure.
    #
    # Optionally, text labels can be rendered next to each marker.
    #
    class PointsLayer
      # Creates a new points layer.
      #
      # @param data [Enumerable]
      #   collection of data records
      # @param lon [#call]
      #   callable extracting longitude from a data record
      # @param lat [#call]
      #   callable extracting latitude from a data record
      # @param icon [String, Array<GD::Color>, nil]
      #   path to an icon image, or [fill, stroke] colors,
      #   or nil to generate a random marker
      # @param label [#call, nil]
      #   callable extracting label text from a data record
      # @param font [String, nil]
      #   font path used for labels
      # @param size [Integer]
      #   font size in pixels
      # @param color [Array<Integer>]
      #   label color as RGB array
      def initialize(
        data,
        lon:,
        lat:,
        icon:,
        label: nil,
        font: nil,
        size: 12,
        color: [0, 0, 0],
        font_color: nil,
        count: 0
      )
        @data = data
        @lon = lon
        @lat = lat
        @color = color

        if icon.is_a?(Array) || icon.nil?
          fill, stroke = icon || [GD::GIS::ColorHelpers.random_rgb, GD::GIS::ColorHelpers.random_rgb]
          @icon = build_default_marker(fill, stroke)
        elsif icon == "numeric" || icon == "alphabetic"
          @icon = icon
          @font_color = font_color
        else
          @icon = GD::Image.open(icon)
          @icon.alpha_blending = true
          @icon.save_alpha = true
        end

        @label = label
        @font  = font
        @size  = size
        @r, @g, @b, @a = color
        @a = 0 if @a.nil?
        @count = count

      end

      # Builds a default circular marker icon.
      #
      # @param fill [GD::Color]
      # @param stroke [GD::Color]
      # @return [GD::Image]
      def build_default_marker(fill, stroke)
        size = 32

        img = GD::Image.new(size, size)
        img.antialias = true

        cx = size / 2
        cy = size / 2
        r  = 5

        # stroke
        img.arc(cx, cy, (r * 2) + 4, (r * 2) + 4, 0, 360, stroke)

        # fill
        img.filled_arc(cx, cy, r * 2, r * 2, 0, 360, fill)

        img
      end

      # Renders all points onto the image.
      #
      # @param img [GD::Image] target image
      # @param projector [#call]
      #   callable converting (lon, lat) → (x, y)
      #
      # @return [void]
      def render!(img, projector)

        case @icon
          when "numeric"
              value = @count
          when "alphabetic"
              value = (@count + 96).chr
          else
            value = "*"
        end

        if @icon.is_a?(GD::Image)
          w = @icon.width 
          h = @icon.height
        else
          w = radius_from_text(img, value, font: @font, size: @size) * 2
        end

        @data.each do |row|
          lon = @lon.call(row)
          lat = @lat.call(row)

          x, y = projector.call(lon, lat)

          next unless @label && @font

          text = @label.call(row)
          next if text.nil? || text.strip.empty?
          font_h = @size * 1.1

          if @icon == "numeric" || @icon == "alphabetic"

            draw_symbol_circle!(
                    img: img,
                    x: x,
                    y: y,
                    symbol: value,
                    radius: 12,
                    bg_color: @color,
                    font_color: @font_color,
                    font: @font,
                    font_size: @size
                  )
          else
            img.copy(@icon, x - (w / 2), y - (h / 2), 0, 0, w, h)
          end

          img.text(text,
                  x: x + (w / 2) + 4,
                  y: y + (font_h / 2),
                  size: @size,
                  color: GD::Color.rgba(@r, @g, @b, @a),
                  font: @font)
        end
      end

      # Draws a filled circle (bullet) with a centered numeric label.
      #
      # - x, y: circle center in pixels
      # - y for text() is BASELINE (not top). We compute baseline to center the text.
      def draw_symbol_circle!(img:, x:, y:, symbol:, radius:, bg_color:, font_color:, font:, font_size:, angle: 0.0)
        diameter = radius_from_text(img, symbol, font: font, size: font_size) * 2

        # 1) Bullet background
        img.filled_ellipse(x, y, diameter, diameter, bg_color)

        # 2) Measure text in pixels (matches rendering)
        text = symbol.to_s
        w, h = img.text_bbox(text, font: font, size: font_size, angle: angle)

        # 3) Compute centered position:
        # text() uses baseline Y, so:
        # top_y     = y - h/2
        # baseline  = top_y + h = y + h/2
        text_x = (x - (w / 2.0)).round
        text_y = (y + (h / 2.0)).round

        # 4) Draw number
        img.text(
          text,
          x: text_x,
          y: text_y,
          font: font,
          size: font_size,
          color: font_color
        )
      end

      # Calculates a circle radius that fully contains the rendered text.
      #
      # img      : GD::Image
      # text     : String (number, letters, etc.)
      # font     : path to .ttf
      # size     : font size in points
      # padding  : extra pixels around text (visual breathing room)
      #
      def radius_from_text(img, text, font:, size:, padding: 4)
        w, h = img.text_bbox(
          text.to_s,
          font: font,
          size: size
        )

        # Use the larger dimension to ensure the text fits
        (([w, h].max / 2.0).ceil) + padding
      end

    end
  end
end
