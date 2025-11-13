require 'test_helper'

class V1::ForecastsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = {
      latitude: 12.34,
      longitude: 56.78,
      address: "123 Main St",
      zipcode: "12345"
    }

    GeocoderService.any_instance.stubs(:fetch_location_data).returns(@location)
    Rails.cache.clear
  end

  test "route for show" do
    assert_routing({ method: 'get', path: '/v1/forecast' },
                   { controller: 'v1/forecasts', action: 'show' })
  end

  test "returns success with cached forecast" do
    data = { "address" => "cached", "current_forecast" => { "temp" => "10C" } }
    Rails.cache.write("12345_current_default", data)

    get v1_forecast_url, params: { address: "cached" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "Forecast fetched successfully", body["message"]
  end

  test "returns success with new forecast fetched" do
    fake_weather = { "current" => {}, "daily" => {}, "current_units" => {}, "daily_units" => {} }
    OpenMeteo::ForecastService.any_instance.stubs(:fetch_forecast).returns(fake_weather)
    ForecastSerializer.any_instance.stubs(:as_json).returns({ "ok" => true })

    get v1_forecast_url, params: { address: "City", forecast_type: "daily" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "Forecast fetched successfully", body["message"]
  end

  test "returns error when address missing" do
    get v1_forecast_url
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_match(/Address is required/, body["errors"].join)
  end

  test "returns error for invalid forecast type" do
    get v1_forecast_url, params: { address: "City", forecast_type: "monthly" }
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_match(/Forecast type must be either/, body["errors"].join)
  end
end
