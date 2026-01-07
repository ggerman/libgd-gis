module GD
  module GIS
    class PointsLayer
      def initialize(data, lon:, lat:, icon:, label: nil, font: nil, size: 12, color: [0,0,0])
        @data = data
        @lon = lon
        @lat = lat
        @icon = GD::Image.open(icon)

        @label = label
        @font  = font
        @size  = size
        @color = color

        @icon.alpha_blending = true
        @icon.save_alpha = true
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
