import 'dart:convert' show JsonEncoder;
import 'dart:developer' show log;

import 'package:coffeenity/config/constants/url_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../main.dart';
import '../local/local_storage_services.dart';

class ApiServices {
  final Dio _dio;
  static Future<bool> _hasInternet() async => await InternetConnection().hasInternetAccess;

  ApiServices()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          if (LocalStorageServices.getToken() != null) {
            options.headers['Authorization'] = 'Bearer ${LocalStorageServices.getToken() ?? ''}';
          }
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.data is FormData) {
            _logRequest(options.method, options.uri.toString(), body: {}, headers: options.headers);
          } else {
            _logRequest(options.method, options.uri.toString(), body: options.data, headers: options.headers);
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response.requestOptions.method, response.requestOptions.uri.toString(), response);
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _logError(error.type.name, error.requestOptions.uri.toString(), error, error.stackTrace);
          return handler.next(error);
        },
      ),
    );
  }

  // ==================== Core Methods ====================
  Future<Map<String, dynamic>?> getRequest(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    if (!await _hasInternet()) {
      return null;
    }
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> postRequest(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    if (!await _hasInternet()) {
      return null;
    }
    try {
      final response = await _dio.post(
        path,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  dynamic _handleError(DioException error) {
    String message = "An error occurred";

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout";
        break;
      case DioExceptionType.badResponse:
        message = _parseBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = "Request cancelled";
        break;
      case DioExceptionType.connectionError:
        message = "Connection error";
        break;
      case DioExceptionType.unknown:
        message = "Unknown error";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout";
        break;
      default:
        message = error.message ?? "Unknown error";
    }

    throw message;
  }

  String _parseBadResponse(Response? response) {
    if (response == null) return "Server error";

    final message = response.data is String
        ? response.data
        : (response.data['message'] ?? response.data['error'] ?? "Error: ${response.statusCode}");

    return message.toString();
  }

  final String _logDivider = "------------------------------------------";

  // ==================== Logging ====================
  void _logRequest(String method, String url, {Map<String, dynamic>? body, Map<String, dynamic>? headers}) {
    if (!kIsWeb) {
      final buffer = StringBuffer();
      buffer.writeln('$_logDivider API $method REQUEST $_logDivider');
      buffer.writeln('URL: $url');
      buffer.writeln('HEADERS: ${headers.toString()}');

      if (body != null) {
        buffer.writeln('BODY: ${_prettyJson(body)}');
      }

      buffer.writeln(_logDivider);
      log(buffer.toString());
    }
  }

  void _logResponse(String method, String url, Response response) {
    // final buffer = StringBuffer();
    // buffer.writeln('$_logDivider API $method RESPONSE $_logDivider');
    // buffer.writeln('URL: $url');
    // buffer.writeln('STATUS: ${response.statusCode}');

    // final dynamic responseBody = response.data;

    // if (response.statusCode == 200) {
    //   if (responseBody != null) {
    //     // For other types (String, num, etc.)
    //     buffer.writeln('RESPONSE: $responseBody');
    //   } else {
    //     buffer.writeln('RESPONSE BODY: ${response.data}');
    //   }
    // }

    // buffer.writeln(_logDivider);
    // log(buffer.toString());
  }

  void _logError(String method, String url, dynamic error, StackTrace? stackTrace) {
    if (!kIsWeb) {
      final buffer = StringBuffer();
      buffer.writeln('$_logDivider API $method ERROR $_logDivider');
      buffer.writeln('URL: $url');
      buffer.writeln('ERROR: $error');

      if (stackTrace != null) {
        buffer.writeln('STACK TRACE: $stackTrace');
      }

      buffer.writeln(_logDivider);
      log(buffer.toString());
    }
  }

  String _prettyJson(dynamic json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
  // ==================== Media Methods ====================

  Future<Map<String, dynamic>?> uploadVoiceOrder({required String filePath, required String shopId}) async {
    if (!await _hasInternet()) {
      return null;
    }

    try {
      FormData formData = FormData.fromMap({
        "shopId": shopId,
        "audio": await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });
      // ignore: avoid_print
      print("formData: ${formData.fields}\n ${formData.files.firstOrNull?.value.filename}");
      final response = await _dio.post(UrlConstants.voiceOrder, data: formData);

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> uploadVoiceReOrder({required String filePath}) async {
    if (!await _hasInternet()) {
      return null;
    }

    try {
      FormData formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });
      final response = await _dio.post(UrlConstants.voiceReorder, data: formData);

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  Future<Uint8List?> getPdfAsBytes(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool showLogs = true,
  }) async {
    if (!await _hasInternet()) {
      return null;
    }

    try {
      if (showLogs) {
        _logRequest('GET', path, body: null, headers: headers);
      }

      final response = await _dio.get<Uint8List>(
        path,
        queryParameters: queryParams,
        options: Options(
          headers:
              headers ??
              {
                if (LocalStorageServices.getToken() != null)
                  'Authorization': 'Bearer ${LocalStorageServices.getToken()}',
              },
          responseType: ResponseType.bytes, // This is crucial for getting raw bytes
        ),
      );

      if (showLogs) {
        _logPdfResponse(path, response);
      }

      return _handlePdfResponse(response);
    } on DioException catch (e) {
      if (showLogs) {
        _logError('GET PDF', path, e, e.stackTrace);
      }
      throw _handleError(e);
    }
  }

  void _logPdfResponse(String url, Response response) {
    if (!kIsWeb) {
      final buffer = StringBuffer();
      buffer.writeln('$_logDivider PDF RESPONSE $_logDivider');
      buffer.writeln('URL: $url');
      buffer.writeln('STATUS CODE: ${response.statusCode}');
      buffer.writeln('CONTENT LENGTH: ${response.data?.length ?? 0} bytes');
      buffer.writeln('CONTENT TYPE: ${response.headers.value('content-type')}');
      buffer.writeln(_logDivider);
      log(buffer.toString());
    }
  }

  Uint8List? _handlePdfResponse(Response<Uint8List> response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data != null) {
        // Validate that we actually got PDF data
        final bytes = response.data!;
        if (bytes.isNotEmpty) {
          return bytes;
        } else {
          throw Exception('Empty PDF response');
        }
      } else {
        throw Exception('No PDF data received');
      }
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
