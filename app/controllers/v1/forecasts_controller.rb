# frozen_string_literal: true
# Controller for handling weather forecast requests.
class V1::ForecastsController < ApplicationController
  before_action :verify_params, :find_location, :load_from_cache, only: [:show]

  # GET /v1/forecast
  # Returns weather forecast data.
  # Params:
  # - address: String (required) - The location address.
  # - forecast_type: String (optional) - Type of forecast ('daily' or 'hourly').
  # - forecast_days: Integer (optional) - Number of days for daily forecast.
  # - forecast_hours: Integer (optional) - Number of hours for hourly forecast.
  # Responses:
  # - 200: Success with forecast data.
  # - 400: Bad request due to invalid parameters.
  # - 404: Location not found.
  # - 500: Internal server error.
  def show
    unless @forecast_data
      weather_data = OpenMeteo::ForecastService.new(@location[:latitude], @location[:longitude])
        .fetch_forecast(forecast_params)

      @forecast_data = ForecastSerializer.new(
        weather_data, scope: { address: @location[:address], forecast_type: forecast_type}
      ).as_json

      store_in_cache(@forecast_data)
    end

    success_response('Forecast fetched successfully', @forecast_data, status: :ok)
  end

  private

  # Permits and retrieves parameters.
  def permitted_params
    params.permit(:address, :forecast_type, :forecast_days, :forecast_hours)
  end

  # Helper methods to access permitted parameters.
  def address = permitted_params[:address]
  def forecast_type = permitted_params[:forecast_type]
  def forecast_days = permitted_params[:forecast_days]
  def forecast_hours = permitted_params[:forecast_hours]

  # Validates the presence and correctness of parameters.
  def verify_params
    errors = []
    errors << 'Address is required.' if address.blank?

    if forecast_type.present? && !%w[daily hourly].include?(forecast_type)
      errors << "Forecast type must be either 'daily' or 'hourly'."
    end

    return if errors.empty?

    error_response('Invalid parameters', errors) and return
  end

  # Finds location data based on the provided address.
  def find_location
    @location ||= GeocoderService.new.fetch_location_data(address)
    error_response('Fetching failed', [@location[:error]], status: @location[:status]) if @location[:error].present?
  end

  def forecast_params
    return {} if forecast_type.blank?

    {
      type: forecast_type,
      days: forecast_days,
      hours: forecast_hours
    }.compact_blank
  end

  # Generates a unique cache key based on location and forecast parameters.
  # @return [String] The generated cache key.
  # Examples:
  #   If zipcode is "12345", forecast_type is "daily", and forecast_days is "3":
  #     cache_key => "12345_daily_3"
  #   If zipcode is "67890", forecast_type is "hourly", and forecast_hours is "12":
  #     cache_key => "67890_hourly_12"
  #   If zipcode is "54321" and no forecast_type is provided:
  #     cache_key => "54321_current"
  #   If zipcode is "12345" and no forecast_days or forecast_hours are provided:
  #     cache_key => "12345_daily" || "12345_hourly" based on forecast_type
  def cache_key
    parts = [@location[:zipcode], forecast_type || "current", forecast_days || forecast_hours]
    parts.compact.join("_")
  end

  # Stores forecast data in the cache with a 30-minute expiration.
  def store_in_cache(data)
    Rails.cache.write(cache_key, data, expires_in: 30.minutes)
  end

  # Loads forecast data from the cache if available.
  def load_from_cache
    @forecast_data = Rails.cache.read(cache_key)
  end
end
