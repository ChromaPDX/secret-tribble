require 'rspec'
require_relative '../lib/api_error.rb'

describe "APIError" do

  it "should take multiple error strings" do
    e = APIError.new
    e.add("first")
    e.add("second")

    expect(e.errors.include?("first")).to be true
    expect(e.errors.include?("second")).to be true
  end

  it "should have a test to see if any errors are present" do
    e = APIError.new
    expect( e.empty? ).to be true

    e.add("derp")
    expect( e.empty? ).to be false
  end

  it "should return a JSON representation of itself" do
    e = APIError.new
    e.add("first")

    j = e.to_json
    jp = JSON.parse(j)

    expect( jp ).to eq({ 'errors' => ["first"]})
  end

end
