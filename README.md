# SerieTrack — N2 Faixa 10

**Estudante:** Eduardo Macedo

Aplicativo Flutter para **pesquisar séries de TV** em uma API real (TVMaze) e
**organizar uma lista pessoal**: o que quero ver, o que estou assistindo, o que
já concluí, com nota própria de 1 a 5 estrelas.

## Problema e público

Quem acompanha várias séries perde o controle do que quer assistir, do que está
vendo e do que achou de cada uma. O SerieTrack junta em um lugar a busca de
informações (sinopse, nota, temporadas, elenco) e o acompanhamento pessoal.
É destinado a qualquer pessoa que assiste séries.

## API externa

- **TVMaze** — https://www.tvmaze.com/api (pública, **não exige chave**).
- Endpoints usados (em `lib/services/tvmaze_service.dart`):
  - `GET /search/shows?q={texto}` → pesquisa;
  - `GET /shows/{id}?embed[]=seasons&embed[]=cast` → detalhes, temporadas e elenco.
- Escolhida por ser gratuita, estável, sem cadastro e com dados ricos (gêneros,
  nota, imagem, sinopse, elenco).

## Requisitos funcionais

| Código | Requisito |
|---|---|
| RF01 | O usuário poderá pesquisar séries pelo nome. |
| RF02 | O sistema consultará a API do TVMaze para localizar as séries e exibirá carregamento, sucesso, lista vazia ou erro (com botão "Tentar novamente"). |
| RF03 | O usuário poderá filtrar os resultados por gênero e ordená-los por relevância, maior nota ou nome. |
| RF04 | O usuário poderá visualizar os detalhes de uma série (nota, estreia, emissora, temporadas, gêneros, sinopse e elenco). |
| RF05 | O usuário poderá adicionar uma série à sua lista e definir o status: Quero ver, Assistindo ou Concluída. |
| RF06 | O usuário poderá dar uma nota pessoal de 1 a 5 estrelas para as séries da lista. |
| RF07 | O usuário poderá ver a lista pessoal com resumo (total, quantidade por status e média das notas), filtrar por status e remover itens (deslizando, com opção "Desfazer"). |

## Telas e navegação

```
HomeScreen (NavigationBar)
 ├── Pesquisar  (SearchScreen)  ──push──> Detalhes (DetailsScreen)
 └── Minha lista (WatchlistScreen) ──push──> Detalhes (DetailsScreen)
```

## Organização do projeto

```
lib/
 ├── main.dart                 # cria o serviço real e o controlador e roda o app
 ├── app.dart                  # MaterialApp (recebe serviço e controlador por parâmetro)
 ├── models/
 │    ├── show.dart            # Show + Show.fromJson
 │    ├── show_details.dart    # ShowDetails, CastMember (+ fromJson com "_embedded")
 │    └── watch_item.dart      # WatchItem e enum WatchStatus
 ├── services/
 │    ├── show_service.dart    # contrato abstrato ShowService + ApiException
 │    └── tvmaze_service.dart  # requisições HTTP reais, JSON e tratamento de erros
 ├── state/
 │    └── watchlist_controller.dart  # lista pessoal (ChangeNotifier)
 ├── screens/                  # home, search, details, watchlist
 ├── widgets/                  # show_card, show_poster, rating_stars, request_state_views
 └── utils/                    # show_filters (filtro/ordenação), html_utils
test/                          # testes unitários e de widget
integration_test/              # teste de integração do fluxo completo
```

## Pontos para a defesa técnica

| Pergunta | Resposta / onde está |
|---|---|
| Onde a API é chamada? | `TvMazeService.searchShows` e `fetchDetails` em `lib/services/tvmaze_service.dart`. As telas chamam o serviço em `_search()` (`search_screen.dart`) e `_loadDetails()` (`details_screen.dart`). |
| Future / async / await | Os métodos do serviço retornam `Future`. As telas usam `await widget.service...` dentro de métodos `async`. |
| O que acontece enquanto a resposta não chega? | O estado vira `RequestStatus.loading` e aparece o `LoadingView` (CircularProgressIndicator). |
| E se a API falhar? | `_get()` converte timeout, falta de rede, status ≠ 200 e JSON inválido em `ApiException` com mensagem amigável. A tela mostra o `ErrorView` com "Tentar novamente". |
| Como o JSON vira objeto? | `jsonDecode` em `_get()` → `Show.fromJson` / `ShowDetails.fromJson`, tratando campos nulos (imagem, nota, emissora). |
| Que estado o usuário altera? | Na pesquisa: texto, gênero e ordenação (`setState`). Na lista: séries, status e notas no `WatchlistController`, que chama `notifyListeners()`; as telas reagem com `ListenableBuilder`. |
| Navegação | `NavigationBar` + `IndexedStack` entre as abas e `Navigator.push` com `MaterialPageRoute` para os detalhes. |
| Por que os testes usam dados falsos? | Para serem previsíveis e não dependerem da internet ou da API estar no ar. `ShowService` é abstrato: o app usa `TvMazeService` e os testes usam `FakeShowService` (`test/helpers/fake_show_service.dart`) ou `MockClient` do pacote http. |

## Testes (22 no total)

- **Unitários** (`test/models`, `test/utils`, `test/state`, `test/services`): conversão de JSON, campos nulos, remoção de HTML, filtro por gênero, ordenação, regras da lista (status, média, nota inválida) e o serviço HTTP com `MockClient` (sucesso, erro 500, JSON inválido, falha de rede).
- **De widget** (`test/widgets`): carregamento → resultados, erro + tentar novamente, resultado vazio, filtro por gênero, detalhes com adicionar/status/nota, e erro nos detalhes.
- **De integração** (`integration_test/app_flow_test.dart`): abrir o app → pesquisar → abrir detalhes → adicionar à lista, marcar como concluída e dar nota 5 → voltar → conferir na aba "Minha lista".

## Como executar

```bash
flutter pub get
flutter run                                   # com o emulador Android aberto
flutter test                                  # testes unitários e de widget
flutter test integration_test                 # teste de integração (no emulador)
flutter analyze
```
