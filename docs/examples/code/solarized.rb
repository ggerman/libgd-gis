module GD
  module GIS
    class Style
      SOLARIZED = Style.new(
        roads: {
          motorway: {
            stroke: [7, 54, 66],      # Base02
            stroke_width: 10,
            fill:   [131, 148, 150],  # Base0
            fill_width: 6
          },
          primary: {
            stroke: [88, 110, 117],   # Base01
            stroke_width: 7,
            fill:   [147, 161, 161],  # Base1
            fill_width: 4
          },
          street: {
            stroke: [147, 161, 161],  # Base1
            stroke_width: 1
          }
        },
        rails: {
          stroke: [203, 75, 22],     # Orange
          stroke_width: 6,
          fill:   [220, 50, 47],     # Red
          fill_width: 4,
          center: [253, 246, 227],   # Base3
          center_width: 1
        },
        water: {
          fill:   [38, 139, 210],    # Blue
          stroke: [42, 161, 152]     # Cyan
        },
        parks: {
          fill: [133, 153, 0]        # Green
        },
        order: [
          :water,
          :park,
          :street,
          :primary,
          :motorway,
          :rail
        ]
      )
    end
  end
end
