# Provides low-level HTTP utilities for connecting to the Open-Meteo API.
module OpenMeteo
  class ApiBase
    FORECAST_URL = 'https://api.open-meteo.com/v1/forecast'.freeze

    # Establishes a Faraday connection with default headers.
    def connect
      Faraday.new(
        headers: { 'Content-Type' => 'application/json' },
      )
    end

    # Performs a GET request to the specified URL with given parameters.
    def get(url, params = {})
      response = connect.get(url, params)
      handle_response(response)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e # Handle connection errors
      { 'error' => "Connection error: #{e.message}" }
    end

    private

    # Parses JSON response body.
    def parse_json(body)
      JSON.parse(body)
    end

    # Handles the HTTP response, parsing JSON or returning an error.
    def handle_response(response)
      return parse_json(response.body) if response.success?

      { 'error' => handle_error(response) }
    rescue JSON::ParserError # Handle JSON parsing errors
      { 'error' => 'Invalid JSON response from the API.' }
    end

    # Handles error responses from the API.
    def handle_error(response)
      response_body = parse_json(response.body)
      response_body['error'] || 'API request failed with status #{response.status}.'
    end
  end
end
