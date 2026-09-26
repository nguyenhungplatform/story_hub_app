import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../app/constants/api_constants.dart';
import '../utils/logger.dart';
import 'api_response.dart';

/// HTTP client dùng chung: gắn Bearer token, giải mã vỏ JSON và ném [ApiException] khi lỗi.
class ApiProvider {
  ApiProvider({http.Client? client}) : client = client ?? http.Client();

  final http.Client client;
  String? token;

  /// Gọi khi server trả về 401 để phiên đăng nhập được xoá.
  void Function()? onUnauthorized;

  Future<ApiResponse<dynamic>> get(String path, {Map<String, dynamic>? query}) => _send('GET', path, query: query);
  Future<ApiResponse<dynamic>> post(String path, {Object? body}) => _send('POST', path, body: body);
  Future<ApiResponse<dynamic>> put(String path, {Object? body}) => _send('PUT', path, body: body);
  Future<ApiResponse<dynamic>> patch(String path, {Object? body}) => _send('PATCH', path, body: body);
  Future<ApiResponse<dynamic>> delete(String path) => _send('DELETE', path);

  Future<ApiResponse<dynamic>> _send(String method, String path, {Map<String, dynamic>? query, Object? body}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$path',
    ).replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
    final request = http.Request(method, uri)..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(await client.send(request).timeout(ApiConstants.timeout));
    } on SocketException {
      throw const ApiException(statusCode: 0, code: 'NETWORK_ERROR', message: 'No connection');
    } on TimeoutException {
      throw const ApiException(statusCode: 0, code: 'NETWORK_ERROR', message: 'Request timeout');
    } on http.ClientException {
      throw const ApiException(statusCode: 0, code: 'NETWORK_ERROR', message: 'No connection');
    }

    AppLogger.info('$method $uri -> ${response.statusCode}');

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) json = decoded;
    } on FormatException {
      json = null;
    }

    final status = response.statusCode;
    // Một số API trả `success: true, data: null` kèm HTTP lỗi, nên phải kiểm tra cả status code.
    if (status >= 200 && status < 300 && json?['success'] == true) {
      return ApiResponse(data: json!['data'], message: json['message'] as String?);
    }

    final error = json?['error'];
    final exception = ApiException(
      statusCode: status,
      code: error is Map ? '${error['code']}' : (status == 401 ? 'UNAUTHORIZED' : 'HTTP_$status'),
      message: error is Map ? '${error['message']}' : (json?['message'] as String? ?? 'Đã có lỗi xảy ra'),
      details: error is Map ? error['details'] as Map<String, dynamic>? : null,
    );
    if (exception.isUnauthorized && token != null) onUnauthorized?.call();
    throw exception;
  }
}
