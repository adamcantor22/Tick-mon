//import 'package:weather/weather_library.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class WeatherTracker {
  static final _weatherAPIKey = 'd3cc8303a3a355c572388fae28684518';
  static Position _currentLocation;
  static WeatherFactory tickStation;

  static void startupWeather() {
    tickStation = new WeatherFactory(_weatherAPIKey);
  }

  static void updateLocation(Position newLocation) {
    _currentLocation = newLocation;
  }

  static Future<Weather> getWeather() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final weather = await tickStation.currentWeatherByLocation(
          _currentLocation.latitude,
          _currentLocation.longitude,
        );
        return weather;
      }
    } on SocketException catch (_) {
      return null;
    }
  }
}
