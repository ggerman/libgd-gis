require "json"

module GD
  module GIS
    class LayerGeoJSON
      def initialize(path, options = {})
        @geojson = JSON.parse(File.read(path))
        @color   = options[:color]
        @icon    = options[:icon]
        @label   = options[:label]
        @font    = options[:font]
        @size    = options[:size] || 10
      end

      def render!(img, projection)
        features = @geojson["features"] || []

        features.each do |f|
            geom = f["geometry"]
            next unless geom

            type   = geom["type"]
            coords = geom["coordinates"]

            case type
            when "Point"
                draw_points(img, projection, [coords], f["properties"])
            when "MultiPoint"
                draw_points(img, projection, coords, f["properties"])
            when "LineString"
                draw_lines(img, projection, [coords])
            when "MultiLineString"
                coords.each { |l| draw_lines(img, projection, [l]) }
            when "Polygon"
                draw_polygons(img, projection, coords)
            when "MultiPolygon"
                coords.each { |p| draw_polygons(img, projection, p) }
            end
        end
      end

      private

      def draw_lines(img, projection, lines)
        color = @color || [120,120,120]

        lines.each do |line|
          pts = line.map { |p| projection.call(p[0], p[1]) }

          pts.each_cons(2) do |(x1, y1), (x2, y2)|
            img.line(x1, y1, x2, y2, color)
          end
        end
      end

    def draw_polygons(img, projection, rings)
      fill   = @color || [200,200,200]
      stroke = @color || [120,120,120]

      rings.each do |ring|
        pts = ring.map { |p| projection.call(p[0], p[1]) }

        # fill
        img.polygon(pts, fill)

        # stroke
        pts.each_cons(2) do |(x1, y1), (x2, y2)|
          img.line(x1, y1, x2, y2, stroke)
        end
      end
    end


    end
  end
end
