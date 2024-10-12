import 'dart:async';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class ShuttleService {
  ShuttleService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<ShuttleStopModel> _data = [];
  List<ShuttleStopModel> get data => _data;
  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider
  final Map<String, String> headers = {
    "accept": "application/json",
    "Authorization": dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY')
  };

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response =
          await (authorizedFetch(dotenv.get('SHUTTLE_API_ENDPOINT'), headers));

      /// parse data
      var data = shuttleStopModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<List<ArrivingShuttle>> getArrivingInformation(stopId) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await (authorizedFetch(
          dotenv.get('SHUTTLE_API_ENDPOINT') + "/$stopId/arrivals", headers));

      /// parse data
      final arrivingData = getArrivingShuttles(_response);
      return arrivingData;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
}
