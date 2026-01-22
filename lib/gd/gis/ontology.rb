require "yaml"

module GD
  module GIS
    class Ontology
      def initialize(path = nil)
        path ||= File.expand_path("ontology.yml", __dir__)
        @rules = YAML.load_file(path)
      end

      def classify(properties, geometry_type: nil)
        @rules.each do |layer, sources|
          sources.each do |source, rules|
            rules.each do |key, values|
              v = (properties[key.to_s] || properties[key.to_sym]).to_s.strip.downcase
              values = values.map { |x| x.to_s.downcase }

              return layer.to_sym if values.any? { |x| v.include?(x) }
            end
          end
        end

        return :points if geometry_type == "Point"

        nil
      end

    end
  end
end
