# frozen_string_literal: true

module GD
  module GIS
    # Resolves bounding box inputs into a normalized WGS84 bbox array.
    #
    # Accepts:
    # - Symbol or String referencing a named extent (e.g. :world, :argentina)
    # - Array in the form [min_lng, min_lat, max_lng, max_lat]
    #
    # Returns a 4-element array of Float values.
    #
    # @example Using a named extent
    #   BBoxResolver.resolve(:europe)
    #
    # @example Using a raw bbox
    #   BBoxResolver.resolve([-10, 35, 5, 45])
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
        return if bbox.is_a?(Array) && bbox.size == 4

        raise ArgumentError,
              "bbox must be [min_lng, min_lat, max_lng, max_lat]"
      end
    end
  end
end
