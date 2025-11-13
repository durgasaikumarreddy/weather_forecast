require 'test_helper'
require 'ostruct'

class GeocoderServiceTest < ActiveSupport::TestCase
  setup do
    @service = GeocoderService.new
  end

  test "returns valid location data when results found" do
    fake_result = OpenStruct.new(data: {
      "lat" => "12.34",
      "lon" => "56.78",
      "name" => "Test City",
      "address" => { "postcode" => "12345", "city" => "Test City" }
    })

    Geocoder.expects(:search).with("Test City").returns([fake_result])

    result = @service.fetch_location_data("Test City")

    assert_equal "12.34", result[:latitude]
    assert_equal "56.78", result[:longitude]
    assert_equal "12345", result[:zipcode]
  end

  test "returns error when no results found" do
    Geocoder.expects(:search).returns([])
    result = @service.fetch_location_data("Nowhere")
    assert_equal "Location not found.", result[:error]
  end

  test "handles exceptions gracefully" do
    Geocoder.expects(:search).raises(StandardError.new("API failure"))
    result = @service.fetch_location_data("Paris")
    assert_match(/Geocoding failed/, result[:error])
  end
end
