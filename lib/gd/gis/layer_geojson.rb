# frozen_string_literal: true

require "json"
require_relative "feature"
require_relative "crs_normalizer"
require_relative "ontology"

module GD
  module GIS
    # Loads GeoJSON files into renderable Feature objects.
    #
    # This class is responsible for:
    # - Parsing GeoJSON files
    # - Normalizing coordinates across CRS definitions
    # - Classifying features using an ontology
    # - Producing {GD::GIS::Feature} instances
    #
    # All coordinates are normalized to WGS84
    # in [longitude, latitude] order.
    #
    class LayerGeoJSON
      # Loads a GeoJSON file and returns normalized features.
      #
      # @param path [String] path to GeoJSON file
      # @return [Array<GD::GIS::Feature>]
      # @raise [JSON::ParserError] if the file is invalid JSON
      # @raise [Errno::ENOENT] if the file does not exist
      def self.load(source)
        data = normalize_source(source)

        validate_geojson!(data)

        # 1) Detect CRS
        crs_name   = data["crs"]&.dig("properties", "name")
        normalizer = CRS::Normalizer.new(crs_name)

        # 2) Load ontology
        ontology = Ontology.new

        # 3) Normalize geometries + classify
        data["features"].map do |feature|
          geometry   = feature["geometry"]
          properties = feature["properties"] || {}

          raise ArgumentError, "Missing geometry" unless geometry
          raise ArgumentError, "Missing geometry type" unless geometry["type"]
          raise ArgumentError, "Missing coordinates" unless geometry["coordinates"]

          normalize_geometry!(geometry, normalizer)

          layer = ontology.classify(
            properties,
            geometry_type: geometry["type"]
          )

          Feature.new(geometry, properties, layer)
        end
      end

      def self.normalize_source(source)
        case source
        when Hash
          source

        when String
          begin
            JSON.parse(source)
          rescue JSON::ParserError
            raise ArgumentError, "File not found: #{source}" unless File.exist?(source)

            JSON.parse(File.read(source))
          end

        else
          raise ArgumentError, "Unsupported GeoJSON source: #{source.class}"
        end
      end

      def self.validate_geojson!(data)
        raise ArgumentError, "GeoJSON must be an object" unless data.is_a?(Hash)

        raise ArgumentError, "Only FeatureCollection is supported" unless data["type"] == "FeatureCollection"

        return if data["features"].is_a?(Array)

        raise ArgumentError, "GeoJSON must contain features array"
      end

      # Normalizes a GeoJSON geometry in-place.
      #
      # Supports 2D and 3D coordinate arrays.
      # Any additional dimensions (e.g. Z) are preserved or ignored
      # depending on the CRS normalizer.
      #
      # @param geometry [Hash] GeoJSON geometry object
      # @param normalizer [CRS::Normalizer]
      # @return [void]
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
