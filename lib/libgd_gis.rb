require "libgd_gis"
require "open-uri"
require "tempfile"
require "gd"

# Namespace for LibGD extensions
module LibGD
  module GIS
    # Represents a single map tile fetched from a remote tile provider.
    class Tile
      # @return [Integer] zoom level
      attr_reader :z

      # @return [Integer] tile X coordinate
      attr_reader :x

      # @return [Integer] tile Y coordinate
      attr_reader :y

      # @return [GD::Image, nil] rendered image
      attr_reader :image

      # Builds a tile using an OSM-compatible XYZ source
      #
      # @param z [Integer] zoom level
      # @param x [Integer] X coordinate
      # @param y [Integer] Y coordinate
      # @return [Tile]
      def self.osm(z:, x:, y:)
        new(
          z: z,
          x: x,
          y: y,
          source: "https://api.maptiler.com/maps/basic/#{z}/#{x}/#{y}.png?key=GetYourOwnKey"
        )
      end

      # @param z [Integer]
      # @param x [Integer]
      # @param y [Integer]
      # @param source [String] remote image URL
      def initialize(z:, x:, y:, source:)
        @z = z
        @x = x
        @y = y
        @source = source
      end

      # Downloads and renders the tile image
      #
      # @return [GD::Image]
      def render
        tmp = Tempfile.new(["tile", ".png"])
        tmp.binmode
        uri = URI(@source)
        response = Net::HTTP.get(uri)
        tmp.write(response)
        tmp.flush

        @image = GD::Image.open(tmp.path)
      ensure
        tmp.close
      end

      # Saves the rendered image to disk
      #
      # @param path [String]
      # @return [void]
      def save(path)
        @image.save(path)
      end
    end
  end
end
