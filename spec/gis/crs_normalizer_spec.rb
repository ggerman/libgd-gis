# frozen_string_literal: true

require "spec_helper"

RSpec.describe GD::GIS::CRS::Normalizer do
  describe "#initialize" do
    it "defaults to CRS84 when nil is given" do
      normalizer = described_class.new(nil)
      result = normalizer.normalize(10, 20)

      expect(result).to eq([10, 20])
    end

    it "accepts string CRS identifiers" do
      normalizer = described_class.new(GD::GIS::CRS::EPSG4326)

      expect(normalizer.normalize(10, 20)).to eq([20, 10])
    end
  end

  describe "#normalize" do
    context "with CRS84" do
      subject(:normalizer) { described_class.new(GD::GIS::CRS::CRS84) }

      it "returns coordinates unchanged" do
        expect(normalizer.normalize(-58.3816, -34.6037))
          .to eq([-58.3816, -34.6037])
      end
    end

    context "with EPSG:4326" do
      subject(:normalizer) { described_class.new(GD::GIS::CRS::EPSG4326) }

      it "swaps latitude and longitude axis order" do
        # input: (lat, lon)
        lat = -34.6037
        lon = -58.3816

        expect(normalizer.normalize(lat, lon))
          .to eq([lon, lat])
      end
    end

    context "with EPSG:3857 (Web Mercator)" do
      subject(:normalizer) { described_class.new(GD::GIS::CRS::EPSG3857) }

      it "converts mercator meters to lon/lat degrees" do
        # Buenos Aires (approx)
        x = -6497895.0
        y = -4123057.0

        lon, lat = normalizer.normalize(x, y)

        expect(lon).to be_within(0.01).of(-58.38)
        expect(lat).to be_within(0.15).of(-34.60)
      end
    end

    context "with Gauss–Krüger Argentina (EPSG:22195)" do
      subject(:normalizer) { described_class.new("EPSG:22195") }

      it "converts GK zone 5 to WGS84 using known reference values" do
        easting  = 500_000
        northing = 6_200_000

        lon, lat = normalizer.normalize(easting, northing)

        expect(lon).to be_within(0.01).of(-60.0)
        expect(lat).to be_within(1.0).of(-34.9)
      end
    end

    context "with unsupported CRS" do
      subject(:normalizer) { described_class.new("EPSG:999999") }

      it "raises an error" do
        expect { normalizer.normalize(0, 0) }
          .to raise_error(ArgumentError, /Unsupported CRS/)
      end
    end
  end
end
