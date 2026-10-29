import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/show.dart';
import '../models/show_details.dart';
import 'show_service.dart';

/// Implementacao real que consome a API publica do TVMaze.
/// Documentacao: https://www.tvmaze.com/api (nao exige chave de acesso).
class TvMazeService implements ShowService {
  TvMazeService({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = 'https://api.tvmaze.com';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// Endpoint: GET /search/shows?q={texto}
  /// Resposta: lista de objetos {"score": ..., "show": {...}}.
  @override
  Future<List<Show>> searchShows(String query) async {
    final uri = Uri.parse('$baseUrl/search/shows')
        .replace(queryParameters: {'q': query});

    final body = await _get(uri);

    if (body is! List) {
      throw const ApiException('Resposta inesperada do servidor.');
    }

    return body
        .map((item) => Show.fromJson(
            (item as Map<String, dynamic>)['show'] as Map<String, dynamic>))
        .toList();
  }

  /// Endpoint: GET /shows/{id}?embed[]=seasons&embed[]=cast
  @override
  Future<ShowDetails> fetchDetails(int id) async {
    final uri = Uri.parse('$baseUrl/shows/$id?embed[]=seasons&embed[]=cast');

    final body = await _get(uri);

    if (body is! Map<String, dynamic>) {
      throw const ApiException('Resposta inesperada do servidor.');
    }

    return ShowDetails.fromJson(body);
  }

  /// Faz a requisicao, valida o status HTTP e converte o corpo de JSON.
  /// Qualquer falha vira uma ApiException com mensagem para o usuario.
  Future<dynamic> _get(Uri uri) async {
    final http.Response response;

    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
          'O servidor demorou para responder. Tente novamente.');
    } catch (_) {
      throw const ApiException(
          'Sem conexao com a internet. Verifique sua rede.');
    }

    if (response.statusCode == 404) {
      throw const ApiException('Serie nao encontrada.');
    }
    if (response.statusCode == 429) {
      throw const ApiException(
          'Muitas requisicoes seguidas. Aguarde alguns segundos.');
    }
    if (response.statusCode != 200) {
      throw ApiException('Erro no servidor (codigo ${response.statusCode}).');
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('Os dados recebidos estao em formato invalido.');
    }
  }
}
