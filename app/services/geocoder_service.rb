# Provides geocoding services using the Geocoder gem.
class GeocoderService
  def fetch_location_data(city_name)
    results = Geocoder.search(city_name)

    if results.any?
      location = results.first.data

      {
        latitude: location["lat"],
        longitude: location["lon"],
        name: location["name"],
        zipcode: location["address"]["postcode"],
        address: location["address"],
      }
    else
      { error: 'Location not found.', status: :not_found }
    end
  rescue StandardError => e # Handle potential errors from Geocoder
    { error: "Geocoding failed: #{e.message}", status: :internal_server_error }
  end
end
