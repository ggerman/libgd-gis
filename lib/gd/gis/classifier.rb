module GD
  module GIS
    class Classifier
      def self.road(feature)
        tags = feature.properties || {}

        case tags["highway"]
        when "motorway", "trunk"
          :motorway
        when "primary", "primary_link"
          :primary
        when "secondary", "secondary_link"
          :secondary
        when "tertiary"
          :street
        when "residential", "living_street"
          :street
        when "service", "track"
          :minor
        else
          nil
        end
      end

      def self.water?(feature)
        p = feature.properties

        p["waterway"] ||
        p["natural"] == "water" ||
        p["fclass"] == "river" ||
        p["fclass"] == "stream"
      end

      def self.rail?(feature)
        tags = feature.properties || {}
        tags["railway"]
      end

      def self.park?(feature)
        tags = feature.properties || {}
        %w[park recreation_ground garden].include?(tags["leisure"]) ||
          %w[park grass forest].include?(tags["landuse"])
      end

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
