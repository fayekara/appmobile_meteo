import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// Représente tous les états possibles de l'écran météo.
enum WeatherStatus { initial, loading, success, error }

/// Le WeatherController est le cœur de l'architecture MVC. Il fait le lien
/// entre le WeatherService (données) et la WeatherView (affichage).
/// Il étend ChangeNotifier pour notifier automatiquement les widgets
/// abonnés lors des changements d'état (couche Controller).
class WeatherController extends ChangeNotifier {
  final WeatherService _service;

  WeatherController({WeatherService? service})
      : _service = service ?? WeatherService();

  // --- Attributs privés (état interne) ---
  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  String _errorMessage = '';
  final List<String> _searchHistory = [];

  static const int _maxHistory = 5;

  // --- Getters publics (lecture seule pour la vue) ---
  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  String get errorMessage => _errorMessage;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  // --- Getters de commodité ---
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasData => _status == WeatherStatus.success;
  bool get hasError => _status == WeatherStatus.error;

  /// Lance la récupération de la météo pour [city].
  ///
  /// Algorithme :
  /// 1. Passer à loading + notifyListeners()
  /// 2. Appeler le service
  /// 3a. Succès -> stocker le modèle, passer à success, mémoriser l'historique
  /// 3b. Erreur -> stocker le message, passer à error
  /// 4. notifyListeners() dans tous les cas
  Future<void> fetchWeather(String city) async {
    final villeSaisie = city.trim();
    if (villeSaisie.isEmpty) {
      _status = WeatherStatus.error;
      _errorMessage = 'Veuillez entrer le nom d\'une ville.';
      notifyListeners();
      return;
    }

    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final resultat = await _service.fetchWeather(villeSaisie);
      _weather = resultat;
      _status = WeatherStatus.success;
      _ajouterHistorique(villeSaisie);
    } on WeatherApiException catch (e) {
      _errorMessage = e.message;
      _status = WeatherStatus.error;
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue.';
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }

  /// Relance la dernière recherche (utilisé par le bouton "Réessayer").
  Future<void> retry() async {
    if (_searchHistory.isNotEmpty) {
      await fetchWeather(_searchHistory.first);
    }
  }

  void _ajouterHistorique(String ville) {
    _searchHistory.removeWhere(
      (v) => v.toLowerCase() == ville.toLowerCase(),
    );
    _searchHistory.insert(0, ville);
    if (_searchHistory.length > _maxHistory) {
      _searchHistory.removeLast();
    }
  }
}
