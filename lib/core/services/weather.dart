import 'dart:async';
import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class WeatherService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final String endpoint = dotenv.get('WEATHER_ENDPOINT');
  WeatherModel _weatherModel = WeatherModel();

  Future<bool> fetchWeatherData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await fetchData(endpoint);

      /// parse data
      _weatherModel = weatherModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  WeatherModel get weatherModel => _weatherModel;
}
