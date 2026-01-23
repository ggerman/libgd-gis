# frozen_string_literal: true

module GD
  module GIS
    # Coordinate Reference System (CRS) helpers and normalizers.
    #
    # This module defines commonly used CRS identifiers and
    # utilities for normalizing coordinates into a single,
    # consistent representation.
    #
    module CRS
      # OGC CRS84 (longitude, latitude)
      CRS84      = "urn:ogc:def:crs:OGC:1.3:CRS84"

      # EPSG:4326 (latitude, longitude axis order)
      EPSG4326   = "EPSG:4326"

      # EPSG:3857 (Web Mercator)
      EPSG3857   = "EPSG:3857"

      # Gauss–Krüger Argentina, zone 5
      #
      # Note: This constant represents a *specific* GK zone
      # and is not a generic Gauss–Krüger definition.
      GK_ARGENTINA = "EPSG:22195"

      # Normalizes coordinates from supported CRS definitions
      # into CRS84 (longitude, latitude in degrees).
      #
      # Supported input CRS:
      # - CRS84
      # - EPSG:4326 (axis order normalization)
      # - EPSG:3857 (Web Mercator)
      # - EPSG:22195 (Gauss–Krüger Argentina, zone 5)
      #
      # All outputs are returned as:
      #   [longitude, latitude] in degrees
      #
      # ⚠️ Projection conversions are intended for mapping
      # and visualization, not for high-precision geodesy.
      #
      class Normalizer
        # Creates a new CRS normalizer.
        #
        # @param crs [String, Symbol, nil]
        #   CRS identifier; defaults to CRS84 if nil
        def initialize(crs)
          @crs = normalize_name(crs)
        end

        # Normalizes a coordinate pair into CRS84.
        #
        # @param lon [Numeric]
        #   first coordinate (meaning depends on input CRS)
        # @param lat [Numeric]
        #   second coordinate (meaning depends on input CRS)
        #
        # @return [Array<Float>]
        #   normalized [longitude, latitude] in degrees
        #
        # @raise [RuntimeError]
        #   if the CRS is not supported
        def normalize(lon, lat)
          case @crs
          when CRS84
            [lon, lat]

          when EPSG4326
            # EPSG:4326 uses (lat, lon)
            [lat, lon]

          when GK_ARGENTINA
            gk_to_wgs84(lon, lat)

          when EPSG3857
            mercator_to_wgs84(lon, lat)

          else
            raise "Unsupported CRS: #{@crs}"
          end
        end

        private

        # Normalizes a CRS name into a comparable string.
        #
        # @param name [Object]
        # @return [String]
        def normalize_name(name)
          return CRS84 if name.nil?

          name.to_s.strip
        end

        # Converts Web Mercator coordinates to WGS84.
        #
        # @param x [Numeric] X coordinate in meters
        # @param y [Numeric] Y coordinate in meters
        # @return [Array<Float>] [longitude, latitude] in degrees
        def mercator_to_wgs84(x, y)
          r = 6378137.0
          lon = (x / r) * 180.0 / Math::PI
          lat = ((2 * Math.atan(Math.exp(y / r))) - (Math::PI / 2)) * 180.0 / Math::PI
          [lon, lat]
        end

        # Converts Gauss–Krüger Argentina (zone 5) coordinates to WGS84.
        #
        # This implementation provides sufficient accuracy for
        # cartographic rendering and visualization.
        #
        # @param easting [Numeric] easting (meters)
        # @param northing [Numeric] northing (meters)
        # @return [Array<Float>] [longitude, latitude] in degrees
        def gk_to_wgs84(easting, northing)
          # Parameters for Argentina GK Zone 5
          a = 6378137.0
          f = 1 / 298.257223563
          e2 = (2 * f) - (f * f)
          lon0 = -60.0 * Math::PI / 180.0 # central meridian zone 5

          x = easting - 500000.0
          y = northing

          m = y
          mu = m / (a * (1 - (e2 / 4) - (3 * e2 * e2 / 64)))

          e1 = (1 - Math.sqrt(1 - e2)) / (1 + Math.sqrt(1 - e2))

          j1 = (3 * e1 / 2) - (27 * (e1**3) / 32)
          j2 = (21 * (e1**2) / 16) - (55 * (e1**4) / 32)

          fp = mu + (j1 * Math.sin(2 * mu)) + (j2 * Math.sin(4 * mu))

          c1 = e2 * (Math.cos(fp)**2)
          t1 = Math.tan(fp)**2
          r1 = a * (1 - e2) / ((1 - (e2 * (Math.sin(fp)**2)))**1.5)
          n1 = a / Math.sqrt(1 - (e2 * (Math.sin(fp)**2)))

          d = x / n1

          lat = fp - ((n1 * Math.tan(fp) / r1) *
                     (((d**2) / 2) - ((5 + (3 * t1) + (10 * c1)) * (d**4) / 24)))

          lon = lon0 + ((d - ((1 + (2 * t1) + c1) * (d**3) / 6)) / Math.cos(fp))

          [lon * 180.0 / Math::PI, lat * 180.0 / Math::PI]
        end
      end
    end
  end
end
