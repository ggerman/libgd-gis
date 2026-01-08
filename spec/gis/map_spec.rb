require "spec_helper"

RSpec.describe GD::GIS::Map do
  let(:bbox) { [-60.6, -31.8, -60.5, -31.7] }

  it "creates a map with a bounding box" do
    map = described_class.new(bbox: bbox, zoom: 15, basemap: :carto_light)
    expect(map).to be_a(described_class)
  end

  it "allows adding a points layer" do
    map = described_class.new(bbox: bbox, zoom: 15, basemap: :carto_light)

    points = [
      { "lat" => -31.75, "lon" => -60.55, "name" => "Test" }
    ]

    map.add_points(
      points,
      lon: ->(p) { p["lon"] },
      lat: ->(p) { p["lat"] },
      label: ->(p) { p["name"] }
    )

    expect { map.render }.not_to raise_error
  end
end



