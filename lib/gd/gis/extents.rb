require "json"

module GD
  module GIS
    module Extents
      DATA_PATH = File.expand_path(
        "data/extents_global.json",
        __dir__
      )

      @extents = nil

      class << self
        def fetch(name)
          load_data!
          @extents.fetch(name.to_s.downcase) do
            raise ArgumentError, "Unknown extent: #{name}"
          end
        end

        def [](name)
          fetch(name)
        end

        def all
          load_data!
          @extents.keys.map(&:to_sym)
        end

        private

        def load_data!
          return if @extents
          @extents = JSON.parse(File.read(DATA_PATH))
        end
      end
    end
  end
end