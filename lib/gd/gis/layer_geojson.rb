require "json"
require_relative "feature"
require_relative "crs_normalizer"
require_relative "ontology"

module GD
  module GIS
    class LayerGeoJSON
      def self.load(path)
        data = JSON.parse(File.read(path))

        # 1) Detect CRS
        crs_name   = data["crs"]&.dig("properties", "name")
        normalizer = CRS::Normalizer.new(crs_name)

        # 2) Load ontology
        ontology = Ontology.new

        # 3) Normalize geometries + classify
        data["features"].map do |f|
          normalize_geometry!(f["geometry"], normalizer)
          layer = ontology.classify(
            f["properties"] || {},
            geometry_type: f["geometry"]["type"]
          )
          Feature.new(f["geometry"], f["properties"], layer)
        end
      end

      # --------------------------------------------
      # CRS normalization (2D + 3D safe)
      # --------------------------------------------
      def self.normalize_geometry!(geometry, normalizer)
        case geometry["type"]

        when "Point"
          geometry["coordinates"] =
            normalizer.normalize(geometry["coordinates"])

        when "LineString"
          geometry["coordinates"] =
            geometry["coordinates"].map { |c| normalizer.normalize(c) }

        when "MultiLineString"
          geometry["coordinates"] =
            geometry["coordinates"].map do |line|
              line.map { |c| normalizer.normalize(c) }
            end

        when "Polygon"
          geometry["coordinates"] =
            geometry["coordinates"].map do |ring|
              ring.map { |c| normalizer.normalize(c) }
            end

        when "MultiPolygon"
          geometry["coordinates"] =
            geometry["coordinates"].map do |poly|
              poly.map do |ring|
                ring.map { |c| normalizer.normalize(c) }
              end
            end
        end
      end

    end
  end
end
