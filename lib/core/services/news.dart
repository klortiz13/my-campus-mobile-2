import 'dart:async';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class NewsService {
  NewsService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  NewsModel _newsModels = NewsModel();

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await authorizedFetch(dotenv.get('NEWS_ENDPOINT'), headers);

      /// parse data
      _newsModels = newsModelFromJson(_response);
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewToken(headers)) {
          return await fetchData();
        }
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  NewsModel get newsModels => _newsModels;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
