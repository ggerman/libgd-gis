# frozen_string_literal: true

require "yaml"

module GD
  module GIS
    # Classifies features into semantic layers using rule-based matching.
    #
    # An Ontology maps feature properties to logical layer identifiers
    # (e.g. :water, :road, :park) based on a YAML rule definition.
    #
    # The ontology is intentionally simple and heuristic-based:
    # - Rules are evaluated in order
    # - The first matching rule wins
    # - Matching is case-insensitive and substring-based
    #
    # This design favors robustness and flexibility over strict
    # schema enforcement.
    #
    class Ontology
      # Creates a new ontology.
      #
      # @param path [String, nil]
      #   path to a YAML ontology file; defaults to `ontology.yml`
      #   shipped with the gem
      #
      # @raise [Errno::ENOENT] if the file does not exist
      # @raise [Psych::SyntaxError] if the YAML is invalid
      def initialize(path = nil)
        path ||= File.expand_path("ontology.yml", __dir__)
        @rules = YAML.load_file(path)
      end

      # Classifies a feature into a semantic layer.
      #
      # Properties are matched against ontology rules using
      # case-insensitive substring comparison.
      #
      # @param properties [Hash]
      #   feature attributes / tags
      # @param geometry_type [String, nil]
      #   GeoJSON geometry type
      #
      # @return [Symbol, nil]
      #   semantic layer identifier, or nil if no rule matches
      #
      # @example
      #   ontology.classify({ "waterway" => "river" })
      #   #=> :water
      #
      # @example
      #   ontology.classify({}, geometry_type: "Point")
      #   #=> :points
      def classify(properties, geometry_type: nil)
        @rules.each do |layer, sources|
          sources.each_value do |rules|
            rules.each do |key, values|
              v = (properties[key.to_s] || properties[key.to_sym]).to_s.strip.downcase
              values = values.map { |x| x.to_s.downcase }

              return layer.to_sym if values.any? { |x| v.include?(x) }
            end
          end
        end

        # Fallback classification
        return :points if geometry_type == "Point"

        nil
      end
    end
  end
end
