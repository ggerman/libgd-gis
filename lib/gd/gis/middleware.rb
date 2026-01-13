module GD
  module GIS
    module CRS
      CRS84      = "urn:ogc:def:crs:OGC:1.3:CRS84"
      EPSG4326   = "EPSG:4326"
      EPSG3857   = "EPSG:3857"
      GK_ARGENTINA = "EPSG:22195"   # Gauss–Krüger Argentina (zone 5 example)

      # Normalize any CRS → CRS84 (lon,lat in degrees)
      class Normalizer
        def initialize(crs)
          @crs = normalize_name(crs)
        end

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

        def normalize_name(name)
          return CRS84 if name.nil?
          name.to_s.strip
        end

        # Web Mercator → WGS84
        def mercator_to_wgs84(x, y)
          r = 6378137.0
          lon = (x / r) * 180.0 / Math::PI
          lat = (2 * Math.atan(Math.exp(y / r)) - Math::PI / 2) * 180.0 / Math::PI
          [lon, lat]
        end

        # Gauss–Krüger Argentina (Zone 5) → WGS84
        # This is enough precision for mapping
        def gk_to_wgs84(easting, northing)
          # Parameters for Argentina GK Zone 5
          a = 6378137.0
          f = 1 / 298.257223563
          e2 = 2*f - f*f
          lon0 = -60.0 * Math::PI / 180.0   # central meridian zone 5

          x = easting - 500000.0
          y = northing

          m = y
          mu = m / (a * (1 - e2/4 - 3*e2*e2/64))

          e1 = (1 - Math.sqrt(1 - e2)) / (1 + Math.sqrt(1 - e2))

          j1 = 3*e1/2 - 27*e1**3/32
          j2 = 21*e1**2/16 - 55*e1**4/32

          fp = mu + j1*Math.sin(2*mu) + j2*Math.sin(4*mu)

          c1 = e2 * Math.cos(fp)**2
          t1 = Math.tan(fp)**2
          r1 = a * (1 - e2) / (1 - e2 * Math.sin(fp)**2)**1.5
          n1 = a / Math.sqrt(1 - e2 * Math.sin(fp)**2)

          d = x / n1

          lat = fp - (n1*Math.tan(fp)/r1) *
            (d**2/2 - (5 + 3*t1 + 10*c1)*d**4/24)

          lon = lon0 + (d - (1 + 2*t1 + c1)*d**3/6) / Math.cos(fp)

          [lon * 180.0 / Math::PI, lat * 180.0 / Math::PI]
        end
      end
    end
  end
end
