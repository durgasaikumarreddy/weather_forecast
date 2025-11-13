require 'test_helper'

class OpenMeteo::ApiBaseTest < ActiveSupport::TestCase
  setup do
    @api = OpenMeteo::ApiBase.new
    @url = OpenMeteo::ApiBase::FORECAST_URL
  end

  test "should define forecast url constant" do
    assert_equal 'https://api.open-meteo.com/v1/forecast', @url
  end

  test "should successfully get and parse JSON response" do
    fake_response = Minitest::Mock.new
    fake_response.expect :success?, true
    fake_response.expect :body, '{"test": "ok"}'

    Faraday::Connection.any_instance
      .expects(:get)
      .returns(fake_response)

    result = @api.get(@url)
    assert_equal({ "test" => "ok" }, result)
  end

  test "should handle failed response" do
    fake_response = Minitest::Mock.new
    fake_response.expect :success?, false
    fake_response.expect :status, 500
    fake_response.expect :body, '{"error": "Internal Server Error"}'

    Faraday::Connection.any_instance
      .expects(:get)
      .returns(fake_response)

    result = @api.get(@url)
    assert_equal({ "error" => "Internal Server Error" }, result)
  end

  test "should handle connection errors" do
    Faraday::Connection.any_instance
      .expects(:get)
      .raises(Faraday::ConnectionFailed.new("timeout"))

    result = @api.get(@url)
    assert_match(/Connection error/, result["error"])
  end
end
