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

          when "EPSG:22195"
            gk_to_wgs84(lon, lat)

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

        # Converts Gauss–Krüger (GK) projected coordinates to WGS84.
        #
        # This method converts easting/northing coordinates from
        # Gauss–Krüger Argentina Zone 5 (EPSG:22195) into
        # WGS84 longitude/latitude (degrees).
        #
        # The implementation is intended for cartographic rendering
        # and visualization purposes, not for high-precision geodesy.
        #
        # @param easting [Numeric]
        #   Easting value in meters.
        #
        # @param northing [Numeric]
        #   Northing value in meters.
        #
        # @return [Array<Float>]
        #   A `[longitude, latitude]` pair in decimal degrees (WGS84).
        #
        # @example Convert Gauss–Krüger coordinates
        #   gk_to_wgs84(580_000, 6_176_000)
        #   # => [longitude, latitude]
        #
        # @note
        #   This method assumes:
        #   - Central meridian: −60°
        #   - False easting: 500,000 m
        #   - WGS84-compatible ellipsoid
        #
        # @see https://epsg.io/22195

        def gk_to_wgs84(easting, northing)
          a = 6378137.0
          f = 1 / 298.257223563
          e2 = (2 * f) - (f * f)
          lon0 = -60.0 * Math::PI / 180.0

          x = easting - 500_000.0
          y = northing - 10_000_000.0

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
