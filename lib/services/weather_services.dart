import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:bigworks_project/models/weather_api.dart';
import 'package:permission_handler/permission_handler.dart';

String? currentCity;

class WeatherService {
  // Get the weather data using user's current location
  Future<Weather> getWeatherData(String? currentCity) async {
    try {
      // Get the user's current position (latitude and longitude)
      Position position = await _determinePosition();

      // Reverse geocode to get the city name from the coordinates
      String city =
          await _getCityFromCoordinates(position.latitude, position.longitude);
      currentCity = city;
      // Call the weather API with the obtained city
      final uri = Uri.parse(
          'http://api.weatherapi.com/v1/forecast.json?key=0f5c4ef7578d4549aab101824252401&q=$city&days=1&aqi=no&alerts=no');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response.statusCode);
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void _handleError(int statusCode) {
    switch (statusCode) {
      case 400:
        print('Bad Request: The request was unacceptable.');
        break;
      case 401:
        print('Unauthorized: Your API key is invalid.');
        break;
      case 403:
        print('Forbidden: You do not have access to this resource.');
        break;
      case 404:
        print('Not Found: The requested resource could not be found.');
        break;
      case 500:
        print('Internal Server Error: Something went wrong on the server.');
        break;
      default:
        print('An unknown error occurred.');
    }
  }
}

// Get the city name from the latitude and longitude using reverse geocoding
Future<String> _getCityFromCoordinates(
    double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return placemarks[0].locality ?? 'Unknown City';
    } else {
      throw Exception('City not found');
    }
  } catch (e) {
    throw Exception('Failed to get city from coordinates: $e');
  }
}

// Get the user's current location
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Check and request location permissions if needed
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // Get and return the current position
  return await Geolocator.getCurrentPosition();
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    if (await Permission.location.request().isGranted) {
      // Permission granted, proceed with getting the location
    } else {
      // Permission denied
      throw Exception('Location permission denied');
    }
  }
}
