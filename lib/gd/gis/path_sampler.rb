require "json"

module GD
  module GIS
    class PathSampler
      def initialize(coords)
        @coords = coords
        @segments = []
        @total = 0.0

        coords.each_cons(2) do |a,b|
          d = haversine(a[0],a[1], b[0],b[1])
          @segments << [a,b,d]
          @total += d
        end
      end

      def point_at(t)
        target = t * @total
        acc = 0.0

        @segments.each do |a,b,d|
          return interpolate(a,b,(target-acc)/d) if acc + d >= target
          acc += d
        end

        @coords.last
      end

      def interpolate(a,b,t)
        [
          a[0] + (b[0]-a[0])*t,
          a[1] + (b[1]-a[1])*t
        ]
      end

      def haversine(lon1,lat1,lon2,lat2)
        r = 6371000
        dlat = (lat2-lat1) * Math::PI/180
        dlon = (lon2-lon1) * Math::PI/180
        a = Math.sin(dlat/2)**2 +
            Math.cos(lat1*Math::PI/180)*Math.cos(lat2*Math::PI/180)*
            Math.sin(dlon/2)**2
        2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      end

      def self.from_geojson(path)
        data = JSON.parse(File.read(path))

        coords =
        if data["features"]
        data["features"][0]["geometry"]["coordinates"]

        elsif data["paths"]
        data["paths"][0]["points"]["coordinates"]

        elsif data["routes"]
        data["routes"][0]["geometry"]["coordinates"]

        else
        raise "Formato de ruta desconocido en #{path}"
        end

        new(coords)
      end
    end
  end
end
