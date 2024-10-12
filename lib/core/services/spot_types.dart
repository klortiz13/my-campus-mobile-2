import 'dart:async';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class SpotTypesService {
  SpotTypesService() { fetchSpotTypesData(); }
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  SpotTypeModel _spotTypeModel = SpotTypeModel();

  Future<bool> fetchSpotTypesData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await fetchData(dotenv.get('SPOT_TYPES_ENDPOINT'));
      _spotTypeModel = spotTypeModelFromJson(_response);
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
  SpotTypeModel get spotTypeModel => _spotTypeModel;
}
