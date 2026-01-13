module GD
  module GIS
    class Style
      LIGHT = Style.new(
        roads: {
          motorway: {
            stroke: [100,100,100],
            stroke_width: 10,
            fill: [245,245,245],
            fill_width: 6
          },
          primary: {
            stroke: [140,140,140],
            stroke_width: 7,
            fill: [240,240,240],
            fill_width: 4
          },
          street: {
            stroke: [220,220,220],
            stroke_width: 1
          }
        },
        rail: {
          stroke: [80,80,80],
          stroke_width: 6,
          fill: [230,70,70],
          fill_width: 4,
          center: [255,255,255],
          center_width: 1
        },
        water: {
          fill: [168,208,255],
          stroke: [120,180,240]
        },
        park: {
          fill: [205,238,203]
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
