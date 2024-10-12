import 'dart:async';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_helper/app_networking.dart';

class StudentIdService {
  final String myStudentProfileApiUrl =
      dotenv.get('MY_STUDENT_PROFILE_API_ENDPOINT');
  final String myStudentContactApiUrl =
      dotenv.get('MY_STUDENT_CONTACT_API_ENDPOINT');

  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  StudentIdNameModel _studentIdNameModel = StudentIdNameModel();
  StudentIdPhotoModel _studentIdPhotoModel = StudentIdPhotoModel();
  StudentIdProfileModel _studentIdProfileModel = StudentIdProfileModel();

  //Removed term (not used)
  Future<bool> fetchStudentIdName(Map<String, String> headers) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await authorizedFetch(
          myStudentContactApiUrl + '/display_name', headers);

      /// parse data
      _studentIdNameModel = studentIdNameModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  //Removed term (not used)
  Future<bool> fetchStudentIdPhoto(Map<String, String> headers) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await authorizedFetch(
          myStudentContactApiUrl + '/photo', headers);

      /// parse data
      _studentIdPhotoModel = studentIdPhotoModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Removed term (not used)
  Future<bool> fetchStudentIdProfile(Map<String, String> headers) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await authorizedFetch(
          myStudentProfileApiUrl + '/profile', headers);

      _studentIdProfileModel = studentIdProfileModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  StudentIdNameModel get studentIdNameModel => _studentIdNameModel;
  StudentIdPhotoModel get studentIdPhotoModel => _studentIdPhotoModel;
  StudentIdProfileModel get studentIdProfileModel => _studentIdProfileModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
