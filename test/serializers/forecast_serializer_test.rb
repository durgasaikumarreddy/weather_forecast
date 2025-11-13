require 'test_helper'

class ForecastSerializerTest < ActiveSupport::TestCase
  setup do
    @data = {
      "current" => { "temperature_2m" => 20 },
      "current_units" => { "temperature_2m" => "°C" },
      "daily" => {
        "temperature_2m_min" => [10],
        "temperature_2m_max" => [25],
        "temperature_2m_mean" => [18],
        "time" => ["2025-11-13"]
      },
      "daily_units" => {
        "temperature_2m_min" => "°C",
        "temperature_2m_max" => "°C",
        "temperature_2m_mean" => "°C"
      },
      "hourly" => {
        "time" => ["12:00"],
        "temperature_2m" => [22]
      },
      "hourly_units" => { "temperature_2m" => "°C" }
    }
  end

  test "serializes current forecast correctly" do
    serializer = ForecastSerializer.new(@data, scope: { address: "Test", forecast_type: nil })
    result = serializer.as_json

    assert_equal "Test", result[:address]
    assert_match /°C/, result[:current_forecast][:temperature]
  end

  test "includes daily extended forecast when forecast_type is daily" do
    serializer = ForecastSerializer.new(@data, scope: { address: "Test", forecast_type: "daily" })
    result = serializer.as_json

    assert result[:extended_daily_forecast].present?
    assert_equal "2025-11-13", result[:extended_daily_forecast].first[:date]
  end

  test "includes hourly extended forecast when forecast_type is hourly" do
    serializer = ForecastSerializer.new(@data, scope: { address: "Test", forecast_type: "hourly" })
    result = serializer.as_json

    assert result[:extended_hourly_forecast].present?
    assert_equal "12:00", result[:extended_hourly_forecast].first[:time]
  end
end
