import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'controllers/weather_controller.dart';
import 'views/weather_view.dart';

Future<void> main() async {
  // Nécessaire avant tout appel asynchrone précédant runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de locale française pour le formatage des
  // dates avec intl (utilisé par WeatherUtils.formatDate).
  await initializeDateFormatting('fr_FR', null);

  // Verrouille l'application en orientation portrait.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Rend la barre de statut transparente pour un rendu immersif avec le
  // dégradé de fond de la vue météo.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AppMeteo());
}

/// Racine de l'application. Injecte le WeatherController dans l'arbre de
/// widgets grâce à ChangeNotifierProvider (couche Controller accessible à
/// toute l'app).
class AppMeteo extends StatelessWidget {
  const AppMeteo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherController(),
      child: MaterialApp(
        title: 'Application Météo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const WeatherView(),
      ),
    );
  }
}
