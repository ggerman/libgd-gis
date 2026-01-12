require "json"
require_relative "feature"

module GD
  module GIS
    class LayerGeoJSON
      def self.load(path)
        data = JSON.parse(File.read(path))
        features = data["features"]
        features.map do |f|
          Feature.new(f["geometry"], f["properties"])
        end
      end
    end
  end
end
