module GD
  module GIS
    module BBoxResolver
      def self.resolve(bbox)
        case bbox
        when Symbol, String
          Extents.fetch(bbox)

        when Array
          validate!(bbox)
          bbox.map(&:to_f)

        else
          raise ArgumentError,
            "bbox must be Symbol, String or [min_lng, min_lat, max_lng, max_lat]"
        end
      end

      def self.validate!(bbox)
        unless bbox.is_a?(Array) && bbox.size == 4
          raise ArgumentError,
            "bbox must be [min_lng, min_lat, max_lng, max_lat]"
        end
      end
    end
  end
end