import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/models/notifications_freefood.dart';
import 'package:network_helper/app_networking.dart';

class FreeFoodService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  FreeFoodModel? _data;
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  FreeFoodService();

  Future<bool> fetchData(String id) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      var _response = await authorizedFetch(
          dotenv.get('NOTIFICATIONS_GOING_ENDPOINT') +
              'events/' + id + '/rsvpCount', headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await getNewToken(headers)) {
          return await fetchData(id);
        }
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchMaxCount(String id) async {
    _error = null; _isLoading = true;
    try {
      String _url = dotenv.get('NOTIFICATIONS_GOING_ENDPOINT') +
          'events/' + id + '/rsvpLimit';

      /// fetch data
      var _response = await authorizedFetch(_url, headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await getNewToken(headers)) {
          return await fetchMaxCount(id);
        }
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateCount(String id, Map<String, dynamic> body) async {
    _error = null; _isLoading = true;
    try {
      String _url = dotenv.get('NOTIFICATIONS_GOING_ENDPOINT') + 'events/' + id;
      /// update count
      var _response = await authorizedPut(_url, headers, body);
      return _response != null ? true : throw (_response.toString());
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await getNewToken(headers)) {
          return await updateCount(id, body);
        }
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // getters
  String? get error => _error;
  FreeFoodModel? get freeFoodModel => _data;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
