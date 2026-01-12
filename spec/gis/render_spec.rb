require "spec_helper"

RSpec.describe "Rendering pipeline" do
  let(:bbox) { [-60.6, -31.8, -60.5, -31.7] }

  xit "renders a PNG file" do
    map = GD::GIS::Map.new(bbox: bbox, zoom: 15, basemap: :carto_light)

    points = [
      { "lat" => -31.75, "lon" => -60.55, "name" => "Point" }
    ]

    map.add_points(
      points,
      lon: ->(p) { p["lon"] },
      lat: ->(p) { p["lat"] },
      label: ->(p) { p["name"] }
    )

    map.render
    map.save("tmp/test.png")

    img = load_png("tmp/test.png")

    expect(img.width).to be > 0
    expect(img.height).to be > 0
  end
end
