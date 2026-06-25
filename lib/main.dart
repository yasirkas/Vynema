import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/providers.dart';
import 'features/favorites/data/favorites_repository.dart';
import 'features/favorites/presentation/providers/favorites_provider.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env', isOptional: true);

  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox(FavoritesRepository.boxName);
  final settingsBox = await Hive.openBox('settings');

  FlutterNativeSplash.remove();

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
