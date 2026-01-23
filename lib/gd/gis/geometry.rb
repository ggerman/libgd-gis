# frozen_string_literal: true

module GD
  module GIS
    # Geometry and projection helpers for Web Mercator maps.
    #
    # This module provides low-level utilities for:
    # - Web Mercator (EPSG:3857) projection math
    # - Bounding box manipulation
    # - Viewport fitting
    # - Simple geometric operations for visualization
    #
    # All longitude/latitude values are assumed to be in WGS84
    # (EPSG:4326), unless explicitly stated otherwise.
    #
    # ⚠️ These helpers are intended for *rendering and visualization*,
    # not for precise geospatial analysis.
    #
    module Geometry
      # Web Mercator tile size in pixels
      TILE_SIZE = 256.0

      # Maximum latitude supported by Web Mercator
      MAX_LAT   = 85.05112878

      # Validates a bounding box.
      #
      # @param bbox [Array<Float>]
      #   [min_lng, min_lat, max_lng, max_lat]
      # @raise [ArgumentError] if the bbox is invalid
      # @return [void]
      def self.validate_bbox!(bbox)
        return if bbox.is_a?(Array) && bbox.size == 4

        raise ArgumentError, "bbox must be [min_lng, min_lat, max_lng, max_lat]"
      end

      # Validates a coordinate array.
      #
      # @param coords [Array<Array<Float>>]
      # @raise [ArgumentError] if the coordinates are invalid
      # @return [void]
      def self.validate_coords!(coords)
        return if coords.is_a?(Array) && coords.size >= 2

        raise ArgumentError, "coords must be an Array of at least 2 points"
      end

      # Converts longitude to Web Mercator X coordinate.
      #
      # @param lng [Float] longitude in degrees
      # @param zoom [Integer] zoom level
      # @return [Float] X coordinate in pixels
      def self.lng_to_x(lng, zoom)
        ((lng + 180.0) / 360.0) * TILE_SIZE * (2**zoom)
      end

      # Converts latitude to Web Mercator Y coordinate.
      #
      # Latitude values are clamped to the valid Web Mercator range.
      #
      # @param lat [Float] latitude in degrees
      # @param zoom [Integer] zoom level
      # @return [Float] Y coordinate in pixels
      def self.lat_to_y(lat, zoom)
        lat = lat.clamp(-MAX_LAT, MAX_LAT)
        lat_rad = lat * Math::PI / 180.0
        n = Math.log(Math.tan((Math::PI / 4.0) + (lat_rad / 2.0)))
        (1.0 - (n / Math::PI)) / 2.0 * TILE_SIZE * (2**zoom)
      end

      # Converts Web Mercator X coordinate to longitude.
      #
      # @param x [Float] X coordinate in pixels
      # @param zoom [Integer] zoom level
      # @return [Float] longitude in degrees
      def self.x_to_lng(x, zoom)
        ((x / (TILE_SIZE * (2**zoom))) * 360.0) - 180.0
      end

      # Converts Web Mercator Y coordinate to latitude.
      #
      # @param y [Float] Y coordinate in pixels
      # @param zoom [Integer] zoom level
      # @return [Float] latitude in degrees
      def self.y_to_lat(y, zoom)
        n = Math::PI - (2.0 * Math::PI * y / (TILE_SIZE * (2**zoom)))
        180.0 / Math::PI * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n)))
      end

      # Computes a viewport bounding box fitted to an image size.
      #
      # @param bbox [Array<Float>]
      #   input bounding box [min_lng, min_lat, max_lng, max_lat]
      # @param zoom [Integer] zoom level
      # @param width [Integer] image width in pixels
      # @param height [Integer] image height in pixels
      # @return [Array<Float>] fitted bounding box
      def self.viewport_bbox(bbox:, zoom:, width:, height:)
        validate_bbox!(bbox)

        min_lng, min_lat, max_lng, max_lat = bbox

        center_lng = (min_lng + max_lng) / 2.0
        center_lat = (min_lat + max_lat) / 2.0

        center_x = lng_to_x(center_lng, zoom)
        center_y = lat_to_y(center_lat, zoom)

        half_w = width  / 2.0
        half_h = height / 2.0

        min_x = center_x - half_w
        max_x = center_x + half_w
        min_y = center_y - half_h
        max_y = center_y + half_h

        [
          x_to_lng(min_x, zoom),
          y_to_lat(max_y, zoom),
          x_to_lng(max_x, zoom),
          y_to_lat(min_y, zoom)
        ]
      end

      # Creates a naive buffer polygon around a line.
      #
      # ⚠️ This uses an approximate meters-to-degrees conversion
      # and is intended for visualization only.
      #
      # @param coords [Array<Array<Float>>]
      #   array of [lng, lat] points
      # @param meters [Numeric] buffer distance (approximate)
      # @return [Array<Array<Float>>] polygon coordinates
      def self.buffer_line(coords, meters)
        validate_coords!(coords)

        left  = []
        right = []

        coords.each_cons(2) do |a, b|
          x1, y1 = a
          x2, y2 = b

          dx = x2 - x1
          dy = y2 - y1

          len = Math.sqrt((dx * dx) + (dy * dy))
          next if len.zero?

          nx = -dy / len
          ny =  dx / len

          off = meters / 111_320.0

          left  << [x1 + (nx * off), y1 + (ny * off)]
          right << [x1 - (nx * off), y1 - (ny * off)]
        end

        x2, y2 = coords.last
        left  << [x2, y2]
        right << [x2, y2]

        left + right.reverse
      end

      # Projects geographic coordinates into pixel space relative to a bbox.
      #
      # @param lng [Float] longitude
      # @param lat [Float] latitude
      # @param bbox [Array<Float>] reference bounding box
      # @param zoom [Integer] zoom level
      # @return [Array<Float>] [x, y] pixel coordinates
      def self.project(lng, lat, bbox, zoom)
        min_lng, _min_lat, _max_lng, max_lat = bbox

        world_x = lng_to_x(lng, zoom)
        world_y = lat_to_y(lat, zoom)

        offset_x = lng_to_x(min_lng, zoom)
        offset_y = lat_to_y(max_lat, zoom)

        [
          world_x - offset_x,
          world_y - offset_y
        ]
      end

      # Computes a bounding box that fits all features in a GeoJSON file.
      #
      # The resulting bbox is padded and adjusted to match the
      # requested image aspect ratio.
      #
      # @param path [String] path to GeoJSON file
      # @param zoom [Integer] zoom level
      # @param width [Integer] image width in pixels
      # @param height [Integer] image height in pixels
      # @param padding_px [Integer] padding in pixels
      # @return [Array<Float>] bounding box
      # @raise [RuntimeError] if no coordinates are found
      def self.bbox_for_image(path, zoom:, width:, height:, padding_px: 80)
        data = JSON.parse(File.read(path))
        points = []

        data["features"].each do |f|
          geom = f["geometry"]
          next unless geom

          collect_points(geom, points)
        end

        raise "No coordinates found in GeoJSON" if points.empty?

        # --------------------------------------------------
        # 1. Project to pixel space
        # --------------------------------------------------
        xs = []
        ys = []

        points.each do |lon, lat|
          xs << lng_to_x(lon, zoom)
          ys << lat_to_y(lat, zoom)
        end

        min_x = xs.min - padding_px
        max_x = xs.max + padding_px
        min_y = ys.min - padding_px
        max_y = ys.max + padding_px

        # --------------------------------------------------
        # 2. Fit bbox to image aspect ratio
        # --------------------------------------------------
        target_ratio = width.to_f / height
        current_ratio = (max_x - min_x) / (max_y - min_y)

        if current_ratio > target_ratio
          # too wide → expand vertically
          new_h = (max_x - min_x) / target_ratio
          delta = (new_h - (max_y - min_y)) / 2.0
          min_y -= delta
          max_y += delta
        else
          # too tall → expand horizontally
          new_w = (max_y - min_y) * target_ratio
          delta = (new_w - (max_x - min_x)) / 2.0
          min_x -= delta
          max_x += delta
        end

        # --------------------------------------------------
        # 3. Convert back to lon/lat
        # --------------------------------------------------
        [
          x_to_lng(min_x, zoom),
          y_to_lat(max_y, zoom),
          x_to_lng(max_x, zoom),
          y_to_lat(min_y, zoom)
        ]
      end

      # Collects all coordinate points from a GeoJSON geometry.
      #
      # @param geom [Hash] GeoJSON geometry
      # @param points [Array] accumulator array
      # @return [void]
      def self.collect_points(geom, points)
        case geom["type"]
        when "Point"
          points << geom["coordinates"]

        when "MultiPoint", "LineString"
          geom["coordinates"].each { |c| points << c }

        when "MultiLineString", "Polygon"
          geom["coordinates"].each do |line|
            line.each { |c| points << c }
          end

        when "MultiPolygon"
          geom["coordinates"].each do |poly|
            poly.each do |ring|
              ring.each { |c| points << c }
            end
          end
        end
      end

      # Builds a bounding box around a point using a radius.
      #
      # Uses a simple spherical approximation.
      #
      # @param lon [Float] longitude
      # @param lat [Float] latitude
      # @param radius_km [Numeric] radius in kilometers
      # @return [Array<Float>] bounding box
      def self.bbox_around_point(lon, lat, radius_km:)
        delta_lat = radius_km / 111.0
        delta_lon = radius_km / (111.0 * Math.cos(lat * Math::PI / 180.0))

        [
          lon - delta_lon,
          lat - delta_lat,
          lon + delta_lon,
          lat + delta_lat
        ]
      end
    end
  end
end
