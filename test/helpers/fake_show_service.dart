import 'dart:async';

import 'package:serie_track/models/show.dart';
import 'package:serie_track/models/show_details.dart';
import 'package:serie_track/services/show_service.dart';

/// Dados simulados usados nos testes (sempre os mesmos = resultados previsiveis).
const fakeShows = [
  Show(
    id: 1,
    name: 'Dark',
    genres: ['Drama', 'Science-Fiction'],
    rating: 8.7,
    summary: 'Uma crianca desaparece e quatro familias buscam respostas.',
    premiered: '2017-12-01',
    status: 'Ended',
    network: 'Netflix',
  ),
  Show(
    id: 2,
    name: 'The Office',
    genres: ['Comedy'],
    rating: 8.5,
    summary: 'O dia a dia de um escritorio.',
    premiered: '2005-03-24',
    status: 'Ended',
    network: 'NBC',
  ),
  Show(
    id: 3,
    name: 'Brooklyn Nine-Nine',
    genres: ['Comedy', 'Crime'],
    summary: 'Uma delegacia de policia bem diferente.',
    premiered: '2013-09-17',
  ),
];

/// Servico falso: implementa o mesmo contrato do servico real,
/// mas nao acessa a internet.
class FakeShowService implements ShowService {
  FakeShowService({
    this.results = fakeShows,
    this.failSearch = false,
    this.failDetails = false,
  });

  List<Show> results;
  bool failSearch;
  bool failDetails;

  /// Quando definido, a busca so termina quando o teste completar o Completer.
  /// Serve para verificar o estado de carregamento.
  Completer<void>? searchGate;

  int searchCalls = 0;
  String? lastQuery;

  @override
  Future<List<Show>> searchShows(String query) async {
    searchCalls++;
    lastQuery = query;
    if (searchGate != null) await searchGate!.future;
    if (failSearch) {
      throw const ApiException(
          'Sem conexao com a internet. Verifique sua rede.');
    }
    return results
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<ShowDetails> fetchDetails(int id) async {
    if (failDetails) {
      throw const ApiException('Erro no servidor (codigo 500).');
    }
    final show = results.firstWhere((s) => s.id == id);
    return ShowDetails(
      show: show,
      seasonCount: 3,
      cast: const [
        CastMember(name: 'Ator Exemplo', character: 'Personagem Exemplo'),
      ],
    );
  }
}
