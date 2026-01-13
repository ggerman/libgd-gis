module GD
  module GIS
    module CRS
      CRS84    = "urn:ogc:def:crs:OGC:1.3:CRS84"
      EPSG4326 = "EPSG:4326"
      EPSG3857 = "EPSG:3857"

      class Normalizer
        def initialize(crs)
          @crs = normalize_name(crs)
        end

        # Accepts:
        #   normalize(lon,lat)
        #   normalize(lon,lat,z)
        #   normalize([lon,lat])
        #   normalize([lon,lat,z])
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
            [lon, lat]
          end
        end

        private

        def normalize_name(name)
          return nil if name.nil?
          name.to_s.strip
        end

        def mercator_to_wgs84(x, y)
          r = 6378137.0
          lon = (x / r) * 180.0 / Math::PI
          lat = (2 * Math.atan(Math.exp(y / r)) - Math::PI / 2) * 180.0 / Math::PI
          [lon, lat]
        end
      end
    end
  end
end
