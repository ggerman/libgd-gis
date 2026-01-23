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
        color: [0, 0, 0]
      )
        @data = data
        @lon = lon
        @lat = lat

        if icon.is_a?(Array) || icon.nil?
          fill, stroke = icon || [GD::GIS::ColorHelpers.random_rgb, GD::GIS::ColorHelpers.random_rgb]
          @icon = build_default_marker(fill, stroke)
        else
          @icon = GD::Image.open(icon)
        end

        @label = label
        @font  = font
        @size  = size
        @color = color

        @icon.alpha_blending = true
        @icon.save_alpha = true
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
        w = @icon.width
        h = @icon.height

        @data.each do |row|
          lon = @lon.call(row)
          lat = @lat.call(row)

          x, y = projector.call(lon, lat)

          # icono
          img.copy(@icon, x - (w / 2), y - (h / 2), 0, 0, w, h)

          # etiqueta opcional
          next unless @label && @font

          text = @label.call(row)
          next if text.nil? || text.strip.empty?

          font_h = @size * 1.1

          img.text(text,
                   x: x + (w / 2) + 4,
                   y: y + (font_h / 2),
                   size: @size,
                   color: @color,
                   font: @font)
        end
      end
    end
  end
end
