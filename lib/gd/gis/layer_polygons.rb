# frozen_string_literal: true

module GD
  module GIS
    # Renders polygon geometries onto a GD image.
    #
    # A PolygonsLayer draws filled polygons with optional
    # stroke outlines. Polygons are expected to be provided
    # as arrays of rings in [longitude, latitude] order.
    #
    class PolygonsLayer
      # @return [Boolean] enables debug rendering
      attr_accessor :debug

      # Creates a new polygons layer.
      #
      # @param polygons [Array<Array<Array<Array<Float>>>>]
      #   array of polygons, each consisting of one or more rings
      # @param fill [GD::Color] fill color
      # @param stroke [GD::Color, nil] stroke color
      # @param width [Integer, nil] stroke width in pixels
      def initialize(polygons, fill:, stroke: nil, width: nil)
        @polygons = polygons
        @fill = fill
        @stroke = stroke
        @width = width
        @debug = false
      end

      # Builds a polygon layer by buffering line features.
      #
      # This is a convenience constructor that converts
      # line geometries into polygon buffers using a naive
      # geometric approximation.
      #
      # @param features [Array<Hash>]
      #   GeoJSON-like features with LineString geometries
      # @param stroke [GD::Color]
      # @param fill [GD::Color]
      # @param width [Numeric]
      #   buffer width (approximate)
      #
      # @return [PolygonsLayer]
      def self.from_lines(features, stroke:, fill:, width:)
        polys = []

        features.each do |f|
          coords = f["geometry"]["coordinates"]
          poly = Geometry.buffer_line(coords, width)
          polys << poly
        end

        new(polys, fill: fill, stroke: stroke)
      end

      # Renders all polygons onto the image.
      #
      # @param img [GD::Image] target image
      # @param projection [#call]
      #   callable converting (lng, lat) → (x, y)
      #
      # @return [void]
      def render!(img, projection)
        @polygons.each do |polygon|
          # polygon = [ ring, ring, ... ]
          polygon.each_with_index do |ring, idx|
            pts = ring.map do |lng, lat|
              projection.call(lng, lat)
            end

            @stroke = GD::GIS::ColorHelpers.random_vivid if @debug
            @fill   = GD::GIS::ColorHelpers.random_vivid if @debug

            if idx.zero?
              # ring exterior
              img.filled_polygon(pts, @fill)
            end

            next unless @stroke

            pts.each_cons(2) do |a, b|
              img.line(a[0], a[1], b[0], b[1], @stroke, thickness: @width || 1)
            end
          end
        end
      end
    end
  end
end
