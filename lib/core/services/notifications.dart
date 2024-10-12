import 'dart:async';
import 'package:campus_mobile_experimental/core/models/topics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class NotificationService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<TopicsModel>? _topicsModel;

  Future<bool> fetchTopics() async {
    _error = null; _isLoading = true;
    try {
      String? response = await fetchData(dotenv.get('NOTIFICATIONS_TOPICS_ENDPOINT'));
      if (response != null) {
        _topicsModel = topicsModelFromJson(response);
        return true;
      } else {
        _error = response;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> postPushToken(Map<String, String> headers, body) async {
    try {
      String? response = await authorizedPost(
          dotenv.get('NOTIFICATIONS_ENDPOINT') + '/register', headers, body);
      if (response == 'Success') {
        return true;
      } else {
        _error = response;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deletePushToken(Map<String, String> headers, String token) async {
    token = Uri.encodeComponent(token);
    try {
      String? response = await authorizedDelete(
          dotenv.get('NOTIFICATIONS_ENDPOINT') + '/token/' + token, headers);
      if (response == 'Success') {
        return true;
      } else {
        _error = response;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String? get error => _error;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  List<TopicsModel>? get topicsModel => _topicsModel;
}
