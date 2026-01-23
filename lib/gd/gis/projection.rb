# frozen_string_literal: true

module GD
  module GIS
    # Projection helpers for Web Mercator–based maps.
    #
    # This module provides low-level projection utilities used
    # throughout the rendering pipeline to convert geographic
    # coordinates (longitude, latitude) into projected and pixel
    # coordinates.
    #
    # All longitude and latitude values are assumed to be in
    # WGS84 (EPSG:4326).
    #
    module Projection
      # Earth radius used for Web Mercator (meters)
      R = 6378137.0

      # Converts longitude to Web Mercator X coordinate.
      #
      # @param lon [Float] longitude in degrees
      # @return [Float] X coordinate in meters
      def self.mercator_x(lon)
        lon * Math::PI / 180.0 * R
      end

      # Converts latitude to Web Mercator Y coordinate.
      #
      # @param lat [Float] latitude in degrees
      # @return [Float] Y coordinate in meters
      def self.mercator_y(lat)
        Math.log(Math.tan((Math::PI / 4) + (lat * Math::PI / 360.0))) * R
      end

      # Projects geographic coordinates into pixel space
      # relative to a bounding box.
      #
      # This method is typically used for viewport-based rendering
      # where a fixed image size is mapped to a geographic extent.
      #
      # @param lon [Float] longitude in degrees
      # @param lat [Float] latitude in degrees
      # @param min_x [Float] minimum Web Mercator X (meters)
      # @param max_x [Float] maximum Web Mercator X (meters)
      # @param min_y [Float] minimum Web Mercator Y (meters)
      # @param max_y [Float] maximum Web Mercator Y (meters)
      # @param width [Integer] image width in pixels
      # @param height [Integer] image height in pixels
      #
      # @return [Array<Integer>] pixel coordinates [x, y]
      def self.lonlat_to_pixel(lon, lat, min_x, max_x, min_y, max_y, width, height)
        x = mercator_x(lon)
        y = mercator_y(lat)

        px = (x - min_x) / (max_x - min_x) * width
        py = height - ((y - min_y) / (max_y - min_y) * height)

        [px.to_i, py.to_i]
      end

      # Web Mercator tile size in pixels
      TILE_SIZE = 256

      # Converts geographic coordinates to global pixel coordinates.
      #
      # This method implements the standard XYZ / Web Mercator
      # tiling scheme used by most web map providers.
      #
      # Latitude values are clamped to the valid Web Mercator range.
      #
      # @param lon [Float] longitude in degrees
      # @param lat [Float] latitude in degrees
      # @param zoom [Integer] zoom level
      #
      # @return [Array<Float>] global pixel coordinates [x, y]
      def self.lonlat_to_global_px(lon, lat, zoom)
        lat = lat.clamp(-85.05112878, 85.05112878)
        n = 2.0**zoom

        x = (lon + 180.0) / 360.0 * n * TILE_SIZE

        lat_rad = lat * Math::PI / 180.0
        y = (1.0 - (Math.log(Math.tan(lat_rad) + (1.0 / Math.cos(lat_rad))) / Math::PI)) / 2.0 * n * TILE_SIZE

        [x, y]
      end
    end
  end
end
