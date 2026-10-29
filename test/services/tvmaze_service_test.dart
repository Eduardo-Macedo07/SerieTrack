import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serie_track/services/show_service.dart';
import 'package:serie_track/services/tvmaze_service.dart';

/// Testa o servico real com um cliente HTTP falso (MockClient):
/// nenhuma requisicao sai para a internet, as respostas sao pre-definidas.
void main() {
  test('searchShows monta a URL correta e converte a resposta', () async {
    late Uri chamada;
    final client = MockClient((request) async {
      chamada = request.url;
      return http.Response(
        jsonEncode([
          {
            'score': 0.9,
            'show': {
              'id': 1,
              'name': 'Dark',
              'genres': ['Drama'],
              'rating': {'average': 8.7},
            },
          },
        ]),
        200,
      );
    });

    final shows = await TvMazeService(client: client).searchShows('dark');

    expect(chamada.path, '/search/shows');
    expect(chamada.queryParameters['q'], 'dark');
    expect(shows.single.name, 'Dark');
    expect(shows.single.rating, 8.7);
  });

  test('status HTTP diferente de 200 vira ApiException', () async {
    final client = MockClient((_) async => http.Response('erro', 500));

    expect(
      TvMazeService(client: client).searchShows('dark'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', contains('codigo 500'))),
    );
  });

  test('JSON invalido vira ApiException', () async {
    final client = MockClient((_) async => http.Response('<html>', 200));

    expect(
      TvMazeService(client: client).fetchDetails(1),
      throwsA(isA<ApiException>()),
    );
  });

  test('falha de rede vira ApiException com mensagem amigavel', () async {
    final client = MockClient((_) async => throw http.ClientException('off'));

    expect(
      TvMazeService(client: client).searchShows('dark'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', contains('Sem conexao'))),
    );
  });
}
