import 'dart:async';
import 'package:campus_mobile_experimental/core/models/scanner_message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class ScannerMessageService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  ScannerMessageModel _scannerMessageModel = ScannerMessageModel();

  Future<bool> fetchData(Map<String, String> headers) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await authorizedFetch(dotenv.get('SCANNER_MESSAGE_ENDPOINT'), headers);

      /// parse data
      _scannerMessageModel = scannerMessageModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  ScannerMessageModel get scannerMessageModel => _scannerMessageModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
