import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/providers.dart';
import 'features/favorites/data/favorites_repository.dart';
import 'features/favorites/presentation/providers/favorites_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the TMDB API key from .env (won't throw if the file is missing).
  await dotenv.load(fileName: '.env', isOptional: true);

  // Initialize local storage and open the boxes up front so the synchronous
  // repositories and notifiers can read them.
  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox(FavoritesRepository.boxName);
  final settingsBox = await Hive.openBox('settings');

  runApp(
    ProviderScope(
      overrides: [
        favoritesBoxProvider.overrideWithValue(favoritesBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const VynemaApp(),
    ),
  );
}
