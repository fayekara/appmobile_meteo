import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// Exception personnalisée levée par [WeatherService] pour représenter
/// un échec métier (clé invalide, ville introuvable, quota atteint...).
/// Elle porte un message déjà prêt à être affiché à l'utilisateur.
class WeatherApiException implements Exception {
  final String message;
  const WeatherApiException(this.message);

  @override
  String toString() => message;
}

/// Le WeatherService a une seule responsabilité : effectuer les appels
/// réseau vers l'API OpenWeather et retourner un [WeatherModel].
/// Il ne gère ni l'affichage, ni l'état de l'application (couche Service).
class WeatherService {
  // TODO : remplacez cette valeur par votre propre clé API OpenWeather.
  // Voir https://openweathermap.org/ -> compte gratuit -> section "API Keys".
  static const String _apiKey = '7b8957ba1c859630862e582cede22069';

  static const String _baseUrl = 'api.openweathermap.org';
  static const String _path = '/data/2.5/weather';

  /// Récupère les données météo actuelles pour la ville [city].
  ///
  /// Lève une [WeatherApiException] avec un message adapté selon le code
  /// HTTP retourné, ou une exception générique en cas de problème réseau
  /// (pas de connexion, DNS, timeout...).
  Future<WeatherModel> fetchWeather(String city) async {
    final uri = Uri.https(_baseUrl, _path, {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'fr',
    });

    try {
      final reponse = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      switch (reponse.statusCode) {
        case 200:
          final data = json.decode(reponse.body) as Map<String, dynamic>;
          return WeatherModel.fromJson(data);

        case 401:
          throw const WeatherApiException(
            'Clé API invalide. Vérifiez votre configuration.',
          );

        case 404:
          throw WeatherApiException(
            'Ville "$city" introuvable. Vérifiez l\'orthographe.',
          );

        case 429:
          throw const WeatherApiException(
            'Limite de requêtes atteinte. Réessayez plus tard.',
          );

        default:
          throw WeatherApiException(
            'Erreur serveur (${reponse.statusCode}).',
          );
      }
    } on WeatherApiException {
      rethrow;
    } catch (e) {
      // Erreurs réseau : pas de connexion, DNS, timeout, etc.
      throw WeatherApiException('Erreur réseau : impossible de contacter le serveur.');
    }
  }
}
