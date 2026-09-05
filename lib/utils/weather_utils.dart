import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Classe utilitaire centralisant les fonctions d'aide réutilisées dans la
/// vue. Constructeur privé : cette classe ne doit jamais être instanciée,
/// seules ses méthodes statiques sont utilisées.
class WeatherUtils {
  WeatherUtils._();

  /// Retourne le dégradé de couleurs correspondant au code icône
  /// OpenWeather (ex : 01d -> soleil, 04d -> nuages, 10d -> pluie).
  /// Le suffixe 'n' (nuit) donne un dégradé plus sombre.
  static List<Color> getGradientColors(String iconCode) {
    final estNuit = iconCode.endsWith('n');

    if (iconCode.startsWith('01')) {
      // Ciel dégagé
      return estNuit
          ? [const Color(0xFF0D1B3E), const Color(0xFF1E3A6E)]
          : [Colors.blue, Colors.lightBlueAccent];
    }
    if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
      // Peu nuageux / nuages épars
      return estNuit
          ? [const Color(0xFF232946), const Color(0xFF3A4374)]
          : [Colors.blue.shade400, Colors.blue.shade200];
    }
    if (iconCode.startsWith('04')) {
      // Nuageux
      return [Colors.blueGrey, Colors.grey];
    }
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      // Pluie / averses
      return [Colors.indigo, Colors.blueAccent];
    }
    if (iconCode.startsWith('11')) {
      // Orage
      return [const Color(0xFF2C3E50), const Color(0xFF4A5A6A)];
    }
    if (iconCode.startsWith('13')) {
      // Neige
      return [Colors.blueGrey.shade200, Colors.white70];
    }
    if (iconCode.startsWith('50')) {
      // Brume / brouillard
      return [Colors.grey.shade600, Colors.grey.shade300];
    }
    // Valeur par défaut
    return [Colors.blueGrey, Colors.grey];
  }

  /// Retourne un emoji représentatif du code icône OpenWeather.
  static String getWeatherEmoji(String iconCode) {
    if (iconCode.startsWith('01')) return '☀️';
    if (iconCode.startsWith('02')) return '🌤️';
    if (iconCode.startsWith('03')) return '☁️';
    if (iconCode.startsWith('04')) return '☁️';
    if (iconCode.startsWith('09')) return '🌧️';
    if (iconCode.startsWith('10')) return '🌦️';
    if (iconCode.startsWith('11')) return '⛈️';
    if (iconCode.startsWith('13')) return '❄️';
    if (iconCode.startsWith('50')) return '🌫️';
    return '🌡️';
  }

  /// Formate une température en chaîne lisible, ex : "23°C".
  static String formatTemp(double temp) => '${temp.round()}°C';

  /// Formate une heure au format HH:mm, ex : "06:42".
  static String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  /// Formate une date complète en français, ex : "mercredi 2 septembre 2026".
  /// Nécessite que `initializeDateFormatting('fr_FR')` ait été appelé
  /// (voir main.dart) avant la première utilisation.
  static String formatDate(DateTime dt) =>
      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dt);

  /// Met en majuscule la première lettre d'une chaîne.
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
