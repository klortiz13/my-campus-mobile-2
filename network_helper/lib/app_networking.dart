import 'dart:async';
import 'dart:developer';
import './network_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final int defaultTimeout = int.parse(dotenv.get('DEFAULT_TIMEOUT'));

Dio _createDio([ResponseType? resType]) => Dio(
    BaseOptions(
      connectTimeout: defaultTimeout,
      receiveTimeout: defaultTimeout,
      responseType: resType
    )
  );

Future<dynamic> fetchData(String url) async {
  Dio dio = _createDio(ResponseType.plain); // No headers, plain format
  final response = await dio.get(url);
  if (response.statusCode == 200) {
    // If server returns an OK response, return the body
    return response.data;
  } else {
    log('Bad response: ${response.statusCode}, data: ${response.data}');
    // If that response was not OK, throw an error.
    throw Exception('Failed to fetch data: ${response.data}');
  }
}

Future<dynamic> authorizedFetch(String url, Map<String, String> headers) async {
  Dio dio = _createDio(ResponseType.plain);
  dio.options.headers = headers;
  final response = await dio.get(url);
  if (response.statusCode == 200) {
    // If server returns an OK response, return the body
    return response.data;
  } else {
    log('Bad response: ${response.statusCode}, data: ${response.data}');
    // If that response was not OK, throw an error.
    throw Exception('Failed to fetch data: ${response.data}');
  }
}

Future<dynamic> authorizedPost(String url, Map<String, String>? headers, dynamic body) async {
  Dio dio = _createDio(); // headers, no plain responseType
  dio.options.headers = headers;
  final response = await dio.post(url, data: body);
  switch (response.statusCode) {
    case 200:
    case 201:
    // If server returns an OK response, return the body
      return response.data;

    case 400:
    // If that response was not OK, throw an error.
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);

    case 401:
      throw Exception(ErrorConstants.authorizedPostErrors +
          ErrorConstants.invalidBearerToken);

    case 404:
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);

    case 500:
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);

    case 409:
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.duplicateRecord + message);

    default:
      throw Exception('${ErrorConstants.authorizedPostErrors} unknown error');
  }
}

// method for implementing exponential backoff for silentLogin
// mimicking existing code from React Native versions of campus-mobile
Future<dynamic> authorizedPublicPost(String url, Map<String, String> headers, dynamic body) async {
  int retries = 0; int waitTime = 0;
  try {
    var response = await authorizedPost(url, headers, body);
    return response;
  } catch (e) {
    // exponential backoff here
    retries++;
    waitTime = TimeConstants.SSO_REFRESH_RETRY_INCREMENT;
    while (retries <= TimeConstants.SSO_REFRESH_MAX_RETRIES) {
      // wait for the wait time to elapse
      await Future.delayed(Duration(milliseconds: waitTime));

      // calculate new wait time (not exponential for now, mimicking previous code)
      waitTime *= TimeConstants.SSO_REFRESH_RETRY_MULTIPLIER;
      // try to log in again
      try {
        var response = await authorizedPost(url, headers, body);
        // no exception thrown, success, return response
        return response;
      } catch (e) {
        // still raising an exception, increment retries and try again
        retries++;
      }
    }
  }
  // if here, silent login has failed, throw exception to inform caller
  throw Exception(ErrorConstants.silentLoginFailed);
}

Future<dynamic> authorizedPut(String url, Map<String, String> headers, dynamic body) async {
  Dio dio = _createDio();
  dio.options.headers = headers;
  final response = await dio.put(url, data: body);
  switch (response.statusCode) {
    case 200:
    case 201:
    // If server returns an OK response, return the body
      return response.data;

    case 400:
    // If that response was not OK, throw an error.
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPutErrors + message);

    case 401:
      throw Exception(ErrorConstants.authorizedPutErrors +
          ErrorConstants.invalidBearerToken);

    case 404:
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPutErrors + message);

    case 500:
      String message = response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPutErrors + message);

    default:
      throw Exception('${ErrorConstants.authorizedPutErrors} unknown error');
  }
}

Future<dynamic> authorizedDelete(String url, Map<String, String> headers) async {
  Dio dio = _createDio();
  dio.options.headers = headers;
  try {
    final response = await dio.delete(url);
    if (response.statusCode == 200) {
      // If server returns an OK response, return the body
      return response.data;
    } else {
      log('Bad response: ${response.statusCode}, data: ${response.data}');
      // If that response was not OK, throw an error.
      throw Exception('Failed to delete data: ${response.data}');
    }
  } on TimeoutException catch (err) {
    // Different errors thrown by the Dio client DioErrorType.RESPONSE
    log(err as String);
  } catch (err) {
    log('network error');
    log(err as String);
    return null;
  }
}

Future<bool> getNewToken(Map<String, String> headers) async {
  final String tokenEndpoint = dotenv.get('NEW_TOKEN_ENDPOINT');
  final Map<String, String> tokenHeaders = {
    'content-type': 'application/x-www-form-urlencoded',
    'Authorization': dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY')
  };
  try {
    var response = await authorizedPost(tokenEndpoint, tokenHeaders,
        'grant_type=client_credentials');
    headers['Authorization'] = 'Bearer ${response['access_token']}';
    return true;
  } catch (e) {
    return false;
  }
}
