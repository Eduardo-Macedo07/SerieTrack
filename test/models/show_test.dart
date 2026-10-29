import 'package:flutter_test/flutter_test.dart';
import 'package:serie_track/models/show.dart';
import 'package:serie_track/models/show_details.dart';
import 'package:serie_track/utils/html_utils.dart';

void main() {
  group('Show.fromJson', () {
    test('converte o JSON completo do TVMaze em um objeto Show', () {
      final json = {
        'id': 526,
        'name': 'The Office',
        'genres': ['Comedy'],
        'premiered': '2005-03-24',
        'status': 'Ended',
        'language': 'English',
        'rating': {'average': 8.5},
        'network': {'id': 1, 'name': 'NBC'},
        'webChannel': null,
        'image': {
          'medium': 'https://static.tvmaze.com/medium.jpg',
          'original': 'https://static.tvmaze.com/original.jpg',
        },
        'summary': '<p>Steve Carell stars in <b>The Office</b>.</p>',
      };

      final show = Show.fromJson(json);

      expect(show.id, 526);
      expect(show.name, 'The Office');
      expect(show.genres, ['Comedy']);
      expect(show.rating, 8.5);
      expect(show.imageUrl, 'https://static.tvmaze.com/medium.jpg');
      expect(show.network, 'NBC');
      expect(show.year, '2005');
      expect(show.summary, 'Steve Carell stars in The Office.');
    });

    test('aceita campos nulos sem quebrar', () {
      final json = {
        'id': 99,
        'name': 'Serie sem dados',
        'genres': <dynamic>[],
        'rating': {'average': null},
        'image': null,
        'summary': null,
        'premiered': null,
        'network': null,
        'webChannel': {'name': 'Netflix'},
      };

      final show = Show.fromJson(json);

      expect(show.rating, isNull);
      expect(show.imageUrl, isNull);
      expect(show.summary, '');
      expect(show.year, isNull);
      expect(show.network, 'Netflix');
    });
  });

  test('ShowDetails.fromJson le temporadas e elenco de "_embedded"', () {
    final json = {
      'id': 1,
      'name': 'Dark',
      'genres': ['Drama'],
      '_embedded': {
        'seasons': [
          {'id': 1},
          {'id': 2},
          {'id': 3},
        ],
        'cast': [
          {
            'person': {'name': 'Louis Hofmann'},
            'character': {'name': 'Jonas Kahnwald'},
          },
        ],
      },
    };

    final details = ShowDetails.fromJson(json);

    expect(details.show.name, 'Dark');
    expect(details.seasonCount, 3);
    expect(details.cast.single.name, 'Louis Hofmann');
    expect(details.cast.single.character, 'Jonas Kahnwald');
  });

  test('stripHtml remove tags e converte entidades', () {
    expect(stripHtml('<p>Tom &amp; Jerry&#39;s <i>show</i></p>'),
        "Tom & Jerry's show");
    expect(stripHtml(null), '');
  });
}
