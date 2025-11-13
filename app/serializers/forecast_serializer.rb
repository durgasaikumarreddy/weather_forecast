# Serializer for formatting forecast data
class ForecastSerializer < ActiveModel::Serializer
  attributes :address, :current_forecast

  def attributes(*args)
    hash = super

    if forecast_type.present?
      key = "extended_#{forecast_type}_forecast".to_sym
      hash[key] = extended_forecast
    end
    hash
  end

  def address
    scope[:address]
  end

  # Formats the current forecast data.
  def current_forecast
    {
      temperature: format_temperature('current', 'temperature_2m'),
      min_temperature: format_temperature('daily', 'temperature_2m_min', 0),
      max_temperature: format_temperature('daily', 'temperature_2m_max', 0)
    }
  end

  # Formats the extended forecast data based on type.
  def extended_forecast
    type = forecast_type

    data(type)['time'].each_with_index.map do |time, index|
      case type
      when 'daily'
        {
          date: time,
          min_temperature: format_temperature('daily', 'temperature_2m_min', index),
          max_temperature: format_temperature('daily', 'temperature_2m_max', index),
          mean_temperature: format_temperature('daily', 'temperature_2m_mean', index),
        }
      when 'hourly'
        {
          time: time,
          temperature: format_temperature('hourly', 'temperature_2m', index),
        }
      end
    end
  end

  private

  def format_temperature(type, key, index = nil)
    data = data(type)
    units = units(type)
    value = index ? data[key][index] : data[key]

    "#{value}#{units[key]}"
  end

  def forecast_type
    scope[:forecast_type]
  end

  def data(type)
    object[type]
  end

  def units(type)
    object["#{type}_units"]
  end
end
