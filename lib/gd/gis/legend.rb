# lib/libgd/gis/legend.rb

module GD
  module GIS
    LegendItem = Struct.new(:color, :label)

    class Legend
      attr_reader :items, :position

      def initialize(position: :bottom_right)
        @position = position
        @items = []
      end

      def add(color, label)
        @items << LegendItem.new(color, label)
      end
    end
  end
end
