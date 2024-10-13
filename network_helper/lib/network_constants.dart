class ErrorConstants {
  static const authorizedPostErrors = 'Failed to upload data: ';
  static const authorizedPutErrors = 'Failed to update data: ';
  static const invalidBearerToken = 'Invalid bearer token';
  static const notAcceptable =
      'DioError [DioErrorType.response]: Http status error [406]';
  static const duplicateRecord =
      'DioError [DioErrorType.response]: Http status error [409]';
  static const invalidMedia =
      'DioError [DioErrorType.response]: Http status error [415]';
  static const silentLoginFailed = "Silent login failed";
  static const locationFailed = "Location was not available";
}

class TimeConstants {
  static const int SSO_REFRESH_MAX_RETRIES = 3;
  static const int SSO_REFRESH_RETRY_INCREMENT = 5000;
  static const int SSO_REFRESH_RETRY_MULTIPLIER = 3;
}