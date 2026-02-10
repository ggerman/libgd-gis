# lib/gd/gis/legend.rb

module GD
  module GIS
    LegendItem = Struct.new(:color, :label)

    # Represents a map legend rendered as part of the final image.
    #
    # A Legend provides visual context for map elements by associating
    # colors or symbols with human-readable labels.
    #
    # Legends are rendered server-side and embedded directly into the
    # resulting map image, allowing the map to be self-explanatory
    # without relying on external UI components.
    #
    # A Legend is typically created and configured via {Map#legend}
    # and rendered automatically during the map rendering pipeline.
    #
    # @example Creating a legend
    #   map.legend do |l|
    #     l.add [76, 175, 80, 0], "Delivered"
    #     l.add [255, 193, 7, 0], "In transit"
    #     l.add [244, 67, 54, 0], "Delayed"
    #
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
