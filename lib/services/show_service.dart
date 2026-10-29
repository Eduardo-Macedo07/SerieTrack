import '../models/show.dart';
import '../models/show_details.dart';

/// Contrato do servico de series.
///
/// O app usa a implementacao real (TvMazeService). Os testes usam uma
/// implementacao falsa (FakeShowService) com dados previsiveis, para nao
/// depender da internet nem da disponibilidade da API.
abstract class ShowService {
  Future<List<Show>> searchShows(String query);

  Future<ShowDetails> fetchDetails(int id);
}

/// Erro com mensagem amigavel para exibir na interface.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
