# frozen_string_literal: true

require "gd"

# LibGD::GIS provides high-level GIS rendering primitives
# built on top of the GD graphics library.
#
# The library is focused on rendering geographic data
# (points, lines, polygons, and GeoJSON) into raster images
# using a layered map model.
#
# ## Core concepts
#
# - {LibGD::GIS::Map} — rendering surface and orchestration
# - {LibGD::GIS::Layer} — drawable data layers
# - {LibGD::GIS::Geometry} — geometric primitives
# - {LibGD::GIS::Projection} — coordinate transformations
#
# ## Typical usage
#
#   map = LibGD::GIS::Map.new(
#                            bbox: bbox,
#                            zoom: zoom,
#                            basemap: :nasa_goes_geocolor
#   )
#   map.style = GD::GIS::Style.load(style_name.yml)
#   map.render
#   map.save("map_name.png")
#
require_relative "gis/color_helpers"
require_relative "gis/style"
require_relative "gis/classifier"

require_relative "gis/feature"
require_relative "gis/map"
require_relative "gis/basemap"
require_relative "gis/projection"
require_relative "gis/geometry"
require_relative "gis/layer_points"
require_relative "gis/layer_lines"
require_relative "gis/layer_polygons"
require_relative "gis/layer_geojson"
