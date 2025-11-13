require 'test_helper'

class OpenMeteo::ForecastServiceTest < ActiveSupport::TestCase
  setup do
    @service = OpenMeteo::ForecastService.new(10.0, 20.0)
  end

  test "builds default params when forecast_params is blank" do
    params = @service.send(:build_params, {})
    assert_equal 10.0, params[:latitude]
    assert_equal %w[temperature_2m_max temperature_2m_min], params[:daily]
    assert_equal 1, params[:forecast_days]
  end

  test "builds daily forecast params correctly" do
    params = @service.send(:build_params, { type: 'daily', days: '5' })
    assert_equal %w[temperature_2m_max temperature_2m_min temperature_2m_mean], params[:daily]
    assert_equal 6, params[:forecast_days] # days + 1
  end

  test "builds hourly forecast params correctly" do
    params = @service.send(:build_params, { type: 'hourly', hours: '12' })
    assert_equal "temperature_2m", params[:hourly]
    assert_equal 12, params[:forecast_hours]
  end

  test "fetch_forecast calls ApiBase#get with correct arguments" do
    @service.expects(:get).with(OpenMeteo::ApiBase::FORECAST_URL, kind_of(Hash)).returns({ "ok" => true })
    result = @service.fetch_forecast(type: 'daily')
    assert_equal({ "ok" => true }, result)
  end
end
