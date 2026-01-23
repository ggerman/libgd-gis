require "spec_helper"

RSpec.describe GD::GIS::Projection do
  it "projects 0,0 to the origin" do
    x = described_class.mercator_x(0)
    y = described_class.mercator_y(0)

    expect(x).to be_within(0.01).of(0)
    expect(y).to be_within(0.01).of(0)
  end

  it "projects positive longitude to positive x" do
    expect(described_class.mercator_x(10)).to be > 0
    expect(described_class.mercator_x(-10)).to be < 0
  end

  it "projects higher latitude to higher y" do
    expect(described_class.mercator_y(40)).to be > described_class.mercator_y(10)
  end
end
