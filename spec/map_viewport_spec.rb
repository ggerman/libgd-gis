# spec/gd/gis/map_viewport_spec.rb

require "spec_helper"
require "gd/gis"

RSpec.describe GD::GIS::Map do
  let(:paris_bbox) { [2.25, 48.80, 2.42, 48.90] }
  let(:zoom)       { 13 }

  let(:style) do
    double(
      "Style",
      order: [],
      roads: {},
      rails: nil,
      water: nil,
      parks: nil
    )
  end

  describe "viewport-based rendering" do
    it "renders an image with the exact requested width and height" do
      map = GD::GIS::Map.new(
        bbox: paris_bbox,
        zoom: zoom,
        basemap: :carto_light,
        width: 350,
        height: 350
      )

      map.style = style
      map.render

      image = map.image

      expect(image).not_to be_nil
      expect(image.width).to eq(350)
      expect(image.height).to eq(350)
    end
  end

  describe "tile-based rendering (legacy)" do
    it "renders an image whose size is derived from tiles" do
      map = GD::GIS::Map.new(
        bbox: paris_bbox,
        zoom: zoom,
        basemap: :carto_light
      )

      map.style = style
      map.render

      image = map.image

      expect(image).not_to be_nil

      # Tile-based images are always multiples of 256
      expect(image.width % 256).to eq(0)
      expect(image.height % 256).to eq(0)
    end
  end
end
