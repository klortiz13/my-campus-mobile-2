import 'dart:async';
import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class MediaService {
  final String endpoint = dotenv.get('TRITON_MEDIA_ENDPOINT');
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<MediaModel>? _data;
  MediaService() { fetchTritonMediaData(); }

  Future<bool> fetchTritonMediaData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await fetchData(endpoint);

      /// parse data
      final data = mediaModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  List<MediaModel>? get mediaModels => _data;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
