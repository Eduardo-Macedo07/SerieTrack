import 'package:flutter/material.dart';

import 'app.dart';
import 'services/tvmaze_service.dart';
import 'state/watchlist_controller.dart';

void main() {
  runApp(
    SerieTrackApp(
      service: TvMazeService(),
      watchlist: WatchlistController(),
    ),
  );
}
