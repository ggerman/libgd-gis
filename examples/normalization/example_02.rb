# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd"
require "gd/gis/geometry"

# --------------------------------------------------
# Input parameters
# --------------------------------------------------
BBOX_ORIGINAL = [-74.05, 40.70, -73.93, 40.88] # Manhattan
ZOOM   = 14
WIDTH  = 800
HEIGHT = 600

# --------------------------------------------------
# 1. Compute the viewport-aware bbox
# --------------------------------------------------
bbox = GD::GIS::Geometry.viewport_bbox(
  bbox: BBOX_ORIGINAL,
  zoom: ZOOM,
  width: WIDTH,
  height: HEIGHT
)

puts "Viewport bbox:"
puts bbox.inspect

# --------------------------------------------------
# 2. Create the image
# --------------------------------------------------
img = GD::Image.new(WIDTH, HEIGHT)

white = GD::Color.rgb(255, 255, 255)
red   = GD::Color.rgb(255,   0,   0)

img.filled_rectangle(0, 0, WIDTH, HEIGHT, white)

# --------------------------------------------------
# 3. Project the CENTER of the FINAL bbox
# --------------------------------------------------
center_lng = (bbox[0] + bbox[2]) / 2.0
center_lat = (bbox[1] + bbox[3]) / 2.0

x, y = GD::GIS::Geometry.project(center_lng, center_lat, bbox, ZOOM)

puts "Projected center:"
puts [x.round(2), y.round(2)].inspect

# --------------------------------------------------
# 4. Draw a visible point
# --------------------------------------------------
img.filled_ellipse(x, y, 12, 12, red)

# --------------------------------------------------
# 5. Save result
# --------------------------------------------------
img.save("output/example_02.png")

