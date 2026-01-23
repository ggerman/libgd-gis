# frozen_string_literal: true

module GD
  module GIS
    # Coordinate Reference System (CRS) helpers and constants.
    #
    # This namespace defines common CRS identifiers and utilities
    # used for normalizing coordinate order and projection.
    #
    module CRS
      # OGC CRS84 (longitude, latitude)
      CRS84    = "urn:ogc:def:crs:OGC:1.3:CRS84"

      # EPSG:4326 (latitude, longitude axis order)
      EPSG4326 = "EPSG:4326"

      # EPSG:3857 (Web Mercator)
      EPSG3857 = "EPSG:3857"

      # Normalizes coordinates from different CRS definitions
      # into a consistent [longitude, latitude] order.
      #
      # This class handles:
      # - Axis order normalization (e.g. EPSG:4326)
      # - Web Mercator (EPSG:3857) to WGS84 conversion
      # - Flexible input formats
      #
      # The output is always expressed as:
      #   [longitude, latitude] in degrees
      #
      class Normalizer
        # Creates a new CRS normalizer.
        #
        # @param crs [String, Symbol, nil]
        #   CRS identifier (e.g. "EPSG:4326", "EPSG:3857", CRS84)
        def initialize(crs)
          @crs = normalize_name(crs)
        end

        # Normalizes coordinates into [longitude, latitude].
        #
        # Accepted input forms:
        #
        #   normalize(lon, lat)
        #   normalize(lon, lat, z)
        #   normalize([lon, lat])
        #   normalize([lon, lat, z])
        #
        # Extra dimensions (e.g. Z) are ignored.
        #
        # @param args [Array<Float, Array<Float>>]
        # @return [Array<Float>, nil]
        #   normalized [lon, lat] or nil if input is invalid
        def normalize(*args)
          lon, lat = args.flatten
          return nil if lon.nil? || lat.nil?

          lon = lon.to_f
          lat = lat.to_f

          case @crs
          when CRS84, nil
            [lon, lat]

          when EPSG4326
            # axis order lat,lon → lon,lat
            [lat, lon]

          when EPSG3857
            mercator_to_wgs84(lon, lat)

          else
            raise ArgumentError, "Unsupported CRS: #{@crs}"
          end
        end

        private

        # Normalizes a CRS name into a comparable string.
        #
        # @param name [Object]
        # @return [String, nil]
        def normalize_name(name)
          return nil if name.nil?

          name.to_s.strip
        end

        # Converts Web Mercator coordinates to WGS84.
        #
        # @param x [Float] X coordinate (meters)
        # @param y [Float] Y coordinate (meters)
        # @return [Array<Float>] [longitude, latitude] in degrees
        def mercator_to_wgs84(x, y)
          r = 6378137.0
          lon = (x / r) * 180.0 / Math::PI
          lat = ((2 * Math.atan(Math.exp(y / r))) - (Math::PI / 2)) * 180.0 / Math::PI
          [lon, lat]
        end
      end
    end
  end
end
