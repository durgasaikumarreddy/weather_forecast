# Provides weather forecast data from the Open-Meteo API.
class OpenMeteo::ForecastService < OpenMeteo::ApiBase
  def initialize(latitude, longitude)
    @latitude = latitude
    @longitude = longitude
  end

  # Fetches the weather forecast based on provided parameters.
  def fetch_forecast(forecast_params = {})
    params = build_params(forecast_params)
    get(FORECAST_URL, params)
  end

  private

  # Builds the request parameters based on forecast type.
  def build_params(forecast_params)
    base_params = {
      latitude: @latitude,
      longitude: @longitude,
      current: "temperature_2m",
    }

    case forecast_params[:type]
    when 'daily'
      base_params.merge!(daily_params(forecast_params))
    when 'hourly'
      base_params.merge!(hourly_params(forecast_params))
      base_params.merge!(default_params)
    else
      base_params.merge!(default_params)
    end
  end

  # Default parameters for current weather and daily forecast.
  def default_params
    {
      daily: %w[temperature_2m_max temperature_2m_min],
      forecast_days: 1,
    }
  end

  # Parameters for daily forecast.
  def daily_params(forecast_params)
    {
      daily: %w[temperature_2m_max temperature_2m_min temperature_2m_mean],
      forecast_days: (forecast_params[:days].presence&.to_i || 3) + 1, # Default to 4 days including today
    }
  end

  # Parameters for hourly forecast.
  def hourly_params(forecast_params)
    {
      hourly: "temperature_2m",
      forecast_hours: forecast_params[:hours].presence&.to_i || 3, # Default to 3 hours
    }
  end
end
