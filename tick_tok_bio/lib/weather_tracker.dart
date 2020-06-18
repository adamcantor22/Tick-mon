import 'package:weather/weather_library.dart';
import 'package:geolocator/geolocator.dart';

class WeatherTracker {
  static final _weatherAPIKey = 'd3cc8303a3a355c572388fae28684518';
  static Position _currentLocation;
  static WeatherStation tickStation;

  static void startupWeather() {
    tickStation = new WeatherStation(_weatherAPIKey);
  }

  static void updateLocation(Position newLocation) {
    _currentLocation = newLocation;
  }

  static Future<Weather> getWeather() async {
    final weather = await tickStation.currentWeather(
      _currentLocation.latitude,
      _currentLocation.longitude,
    );
    return weather;
  }
}
