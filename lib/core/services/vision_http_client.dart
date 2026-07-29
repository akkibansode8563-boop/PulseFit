import 'package:http/http.dart' as http;

abstract class VisionHttpClient {
  Future<http.Response> post(
    Uri uri, {
    required Map<String, String> headers,
    required Object body,
  });
}

class DefaultVisionHttpClient implements VisionHttpClient {
  @override
  Future<http.Response> post(
    Uri uri, {
    required Map<String, String> headers,
    required Object body,
  }) {
    return http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));
  }
}
