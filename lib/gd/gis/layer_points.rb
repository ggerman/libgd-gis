module GD
  module GIS
    class PointsLayer
      def initialize(data, lon:, lat:, icon: nil, label: nil, font: nil, size: 12, color: [0,0,0])

        @data = data
        @lon = lon
        @lat = lat

        if icon
          @icon = GD::Image.open(icon)
        else
          @icon = build_default_marker
        end

        @label = label
        @font  = font
        @size  = size
        @color = color

        @icon.alpha_blending = true
        @icon.save_alpha = true
      end

      def build_default_marker
        size = 32
        img = GD::Image.new(size, size)
        img.alpha_blending = true
        img.save_alpha = true

        transparent = GD::Color.rgba(0,0,0,0)
        img.filled_rectangle(0,0,size,size,transparent)

        white = GD::Color.rgb(255,255,255)
        black = GD::Color.rgb(0,0,0)

        cx = size / 2
        cy = size / 2
        r  = 12

        # borde blanco
        img.arc(cx, cy, r*2+4, r*2+4, 0, 360, white)

        # relleno negro
        img.filled_arc(cx, cy, r*2, r*2, 0, 360, black)

        img
      end

      def render!(img, projector)
        w = @icon.width
        h = @icon.height

        @data.each do |row|
          lon = @lon.call(row)
          lat = @lat.call(row)

          x,y = projector.call(lon,lat)

          # icono
          img.copy(@icon, x - w/2, y - h/2, 0,0,w,h)

          # etiqueta opcional
          if @label && @font
            text = @label.call(row)
            unless text.nil? || text.strip.empty?
              font_h = @size * 1.1

              img.text(text,
                x: x + w/2 + 4,
                y: y + font_h/2,
                size: @size,
                color: @color,
                font: @font
              )
            end
          end
        end
      end
    end
  end
end
