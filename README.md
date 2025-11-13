# 🌦 Weather Forecast API

A simple, modular **Rails API** that fetches and returns weather forecasts using the [Open-Meteo API](https://open-meteo.com/), with geocoding powered by the [Geocoder gem](https://github.com/alexreisner/geocoder).

---

## 🚀 Features

- Fetches **current, daily, or hourly** weather forecasts
- Uses **Open-Meteo public API**
- Caches responses with `Rails.cache` using **redis**
- Handles location lookup via **Geocoder**
- Clean, isolated **service objects**
- Well-structured **Minitest** test suite

---

## 🧩 Architecture Overview

| Component | Role |
|------------|------|
| `OpenMeteo::ApiBase` | Base API client for external requests |
| `OpenMeteo::ForecastService` | Builds parameters and fetches forecast data |
| `GeocoderService` | Converts city names into coordinates |
| `ForecastSerializer` | Formats weather data into API-friendly JSON |
| `V1::ForecastsController` | Handles incoming API requests and responses |

---

## 🧰 Prerequisites

Before running the project, ensure you have the following installed:

**Ruby** 3.2.3
**Rails** 6.1.7.10
**Redis** latest
**Git** latest

---

## ⚙️ Setup

### 1. Clone the Repository

```bash
git clone https://github.com/durgasaikumarreddy/weather_forecast.git
cd weather_forecast
```

### 2. Install Bundler and gems

```bash
gem install bundler -v 2.4.19
bundle install
```

### 3. Start the Rails server

```bash
rails s
```

### 🧪 Run Tests

```bash
rails test
```

---

## 🧱 API Endpoint

GET `/v1/forecast`

Parameters:

| Name | Type | Description |
|-------|------|-------------|
| `address` | String (required) | The location address |
| `forecast_type` | String (optional) | Type of forecast ('daily' or 'hourly') |
| `forecast_days` | Integer (optional) | Number of days for daily forecast |
| `forecast_hours` | Integer (optional) | Number of hours for hourly forecast |

Example Requests:
  GET `/v1/forecast?address=Chicago`
  Response:
  ```bash
  {
    "message": "Forecast fetched successfully",
    "data": {
      "address": {
        "city": "Chicago",
        "municipality": "South Chicago Township",
        "county": "Cook County",
        "state": "Illinois",
        "ISO3166-2-lvl4": "US-IL",
        "country": "United States",
        "country_code": "us"
      },
      "current_forecast": {
        "temperature": "9.0°C",
        "min_temperature": "0.5°C",
        "max_temperature": "12.2°C"
      }
    }
  }
  ```

  GET `/v1/forecast?address=Chicago&forecast_type=daily`
  Response:
  ```bash
  {
    "message": "Forecast fetched successfully",
    "data": {
      "address": {
        "city": "Chicago",
        "municipality": "South Chicago Township",
        "county": "Cook County",
        "state": "Illinois",
        "ISO3166-2-lvl4": "US-IL",
        "country": "United States",
        "country_code": "us"
      },
      "current_forecast": {
        "temperature": "9.0°C",
        "min_temperature": "0.5°C",
        "max_temperature": "12.2°C"
      },
      "extended_daily_forecast": [
        {
          "date": "2025-11-13",
          "min_temperature": "0.5°C",
          "max_temperature": "12.2°C",
          "mean_temperature": "6.4°C"
        },
        {
          "date": "2025-11-14",
          "min_temperature": "4.1°C",
          "max_temperature": "16.9°C",
          "mean_temperature": "8.7°C"
        },
        {
          "date": "2025-11-15",
          "min_temperature": "10.4°C",
          "max_temperature": "18.5°C",
          "mean_temperature": "13.4°C"
        },
        {
          "date": "2025-11-16",
          "min_temperature": "5.6°C",
          "max_temperature": "15.8°C",
          "mean_temperature": "9.6°C"
        }
      ]
    }
  }
  ```

  GET `/v1/forecast?address=Chicago&forecast_type=daily&forecast_days=3`
  Response:
  ```bash
  {
    "message": "Forecast fetched successfully",
    "data": {
      "address": {
        "city": "Chicago",
        "municipality": "South Chicago Township",
        "county": "Cook County",
        "state": "Illinois",
        "ISO3166-2-lvl4": "US-IL",
        "country": "United States",
        "country_code": "us"
      },
      "current_forecast": {
        "temperature": "10.3°C",
        "min_temperature": "0.5°C",
        "max_temperature": "12.2°C"
      },
      "extended_daily_forecast": [
        {
          "date": "2025-11-13",
          "min_temperature": "0.5°C",
          "max_temperature": "12.2°C",
          "mean_temperature": "6.4°C"
        },
        {
          "date": "2025-11-14",
          "min_temperature": "4.1°C",
          "max_temperature": "16.9°C",
          "mean_temperature": "8.8°C"
        },
        {
          "date": "2025-11-15",
          "min_temperature": "10.4°C",
          "max_temperature": "18.5°C",
          "mean_temperature": "13.4°C"
        },
        {
          "date": "2025-11-16",
          "min_temperature": "5.6°C",
          "max_temperature": "15.8°C",
          "mean_temperature": "9.6°C"
        }
      ]
    }
  }
  ```

  GET `/v1/forecast?address=Chicago&forecast_type=hourly`
  Response:
  ```bash
  {
    "message": "Forecast fetched successfully",
    "data": {
      "address": {
        "city": "Chicago",
        "municipality": "South Chicago Township",
        "county": "Cook County",
        "state": "Illinois",
        "ISO3166-2-lvl4": "US-IL",
        "country": "United States",
        "country_code": "us"
      },
      "current_forecast": {
        "temperature": "9.9°C",
        "min_temperature": "0.5°C",
        "max_temperature": "12.2°C"
      },
      "extended_hourly_forecast": [
        {
          "time": "2025-11-13T17:00",
          "temperature": "8.9°C"
        },
        {
          "time": "2025-11-13T18:00",
          "temperature": "10.3°C"
        },
        {
          "time": "2025-11-13T19:00",
          "temperature": "11.6°C"
        }
      ]
    }
  }
  ```

  GET `/v1/forecast?address=Chicago&forecast_type=hourly&forecast_hours=4`
  Response:
  ```bash
  {
    "message": "Forecast fetched successfully",
    "data": {
      "address": {
        "city": "Chicago",
        "municipality": "South Chicago Township",
        "county": "Cook County",
        "state": "Illinois",
        "ISO3166-2-lvl4": "US-IL",
        "country": "United States",
        "country_code": "us"
      },
      "current_forecast": {
        "temperature": "10.3°C",
        "min_temperature": "0.5°C",
        "max_temperature": "12.2°C"
      },
      "extended_hourly_forecast": [
        {
          "time": "2025-11-13T18:00",
          "temperature": "10.3°C"
        },
        {
          "time": "2025-11-13T19:00",
          "temperature": "11.6°C"
        },
        {
          "time": "2025-11-13T20:00",
          "temperature": "12.2°C"
        },
        {
          "time": "2025-11-13T21:00",
          "temperature": "12.1°C"
        }
      ]
    }
  }
  ```

  Error responses:
  ```bash
  {
    "message": "Invalid parameters",
    "errors": [
      "Address is required."
    ]
  }


  {
    "message": "Invalid parameters",
    "errors": [
      "Forecast type must be either 'daily' or 'hourly'."
    ]
  }


  {
    {
      "message": "Fetching failed",
      "errors": [
        "Location not found."
      ]
    }
  }
  ```

## 👤 Author
**SaiKumar Dwarampudi**
- GitHub: [durgasaikumarreddy](https://github.com/durgasaikumarreddy)

