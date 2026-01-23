# frozen_string_literal: true

module GD
  module GIS
    # Classifies geographic features based on their properties.
    #
    # This class provides a set of stateless helpers used to
    # infer semantic categories (roads, water, parks, rails)
    # from feature attribute tags, typically originating from
    # OpenStreetMap or similar datasets.
    #
    # All methods are pure functions and return symbols or booleans
    # suitable for styling or rendering decisions.
    #
    class Classifier
      # Classifies a road feature into a road category.
      #
      # The classification is based on the `highway` tag.
      #
      # @param feature [GD::GIS::Feature]
      # @return [Symbol, nil]
      #   one of:
      #   - :motorway
      #   - :primary
      #   - :secondary
      #   - :street
      #   - :minor
      #   - nil if the feature is not a road
      def self.road(feature)
        tags = feature.properties || {}

        case tags["highway"]
        when "motorway", "trunk"
          :motorway
        when "primary", "primary_link"
          :primary
        when "secondary", "secondary_link"
          :secondary
        when "tertiary", "residential", "living_street"
          :street
        when "service", "track"
          :minor
        end
      end

      # Determines whether a feature represents water.
      #
      # @param feature [GD::GIS::Feature]
      # @return [Boolean] true if the feature is water-related
      def self.water?(feature)
        p = feature.properties

        p["waterway"] ||
          p["natural"] == "water" ||
          p["fclass"] == "river" ||
          p["fclass"] == "stream"
      end

      # Determines whether a feature represents a railway.
      #
      # @param feature [GD::GIS::Feature]
      # @return [Boolean] true if the feature is a rail feature
      def self.rail?(feature)
        tags = feature.properties || {}
        tags["railway"]
      end

      # Determines whether a feature represents a park or green area.
      #
      # @param feature [GD::GIS::Feature]
      # @return [Boolean] true if the feature is a park or green space
      def self.park?(feature)
        tags = feature.properties || {}
        %w[park recreation_ground garden].include?(tags["leisure"]) ||
          %w[park grass forest].include?(tags["landuse"])
      end

      # Classifies the type of water feature.
      #
      # @param feature [GD::GIS::Feature]
      # @return [Symbol]
      #   - :river
      #   - :stream
      #   - :minor (default / fallback)
      def self.water_kind(feature)
        p = feature.properties

        case p["waterway"] || p["fclass"]
        when "river"  then :river
        when "stream" then :stream
        else :minor
        end
      end
    end
  end
end
