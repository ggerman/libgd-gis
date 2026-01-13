module GD
  module GIS
    module Input
      module Detector
        def self.detect(path)
          return :geojson   if geojson?(path)
          return :kml       if kml?(path)
          return :shapefile if shapefile?(path)
          return :osm_pbf   if pbf?(path)
          :unknown
        end

        def self.geojson?(path)
          File.open(path) do |f|
            head = f.read(2048)
            head.include?('"FeatureCollection"') || head.include?('"GeometryCollection"')
          end
        end

        def self.kml?(path)
          File.open(path) { |f| f.read(512).include?("<kml") }
        end

        def self.shapefile?(path)
          File.open(path, "rb") { |f| f.read(4) == "\x00\x00\x27\x0A" }
        end

        def self.pbf?(path)
          File.open(path, "rb") { |f| f.read(2) == "\x1f\x8b" }
        end
      end
    end
  end
end
