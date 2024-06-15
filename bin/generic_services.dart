import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'generic_model.dart';

abstract class GenericService<T> {
  Future<List<T>> getAll();
  Future<T> getById(String id);
  Future<void> create(T entity);
  Future<void> update(String id, T entity);
  Future<void> delete(String id);
}

class GenericServiceImpl<T> implements GenericService<T> {
  final String apiUrl;
  final GenericModel<T> model;
  final Dio _dio;
  final Logger _logger;

  GenericServiceImpl({required this.apiUrl, required Type type})
      : model = GenericModel(type),
        _logger = Logger(),
        _dio = Dio();

  void _handleError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          _logger.e('Bad Request: ${e.response!.data}');
          break;
        case 401:
          _logger.e('Unauthorized: ${e.response!.data}');
          break;
        case 403:
          _logger.e('Forbidden: ${e.response!.data}');
          break;
        case 404:
          _logger.e('Not Found: ${e.response!.data}');
          break;
        case 500:
          _logger.e('Internal Server Error: ${e.response!.data}');
          break;
        default:
          _logger.e('Error: ${e.response!.statusCode} ${e.response!.data}');
      }
    } else {
      _logger.e('Error sending request: $e');
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      final response = await _dio.get(apiUrl);
      Iterable list = response.data;
      return list.map((model) => this.model.fromMap(model)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<T> getById(String id) async {
    try {
      final response = await _dio.get('$apiUrl/$id');
      return model.fromMap(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> create(T entity) async {
    try {
      final response = await _dio.post(
        apiUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode(model.toMap(entity)),
      );
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to create data with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, T entity) async {
    try {
      final response = await _dio.put(
        '$apiUrl/$id',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode(model.toMap(entity)),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update data with status code ${response.statusCode}');
      }

      _logger.i(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final response = await _dio.delete('$apiUrl/$id');
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete data with status code ${response.statusCode}');
      }
      _logger.i(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }
}
