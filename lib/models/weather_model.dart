/// Modèle représentant les données météorologiques renvoyées par l'API
/// OpenWeather. Cette classe ne contient AUCUNE logique métier ni code
/// d'interface : elle sert uniquement à structurer les données (couche M du
/// patron MVC).
class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDegree;
  final String description;
  final String iconCode;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;

  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDegree,
    required this.description,
    required this.iconCode,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  /// Construit une instance de [WeatherModel] à partir de la réponse JSON
  /// brute de l'API OpenWeather (endpoint /data/2.5/weather).
  ///
  /// Utilise un cast sûr `(valeur as num).toDouble()` car l'API renvoie
  /// parfois des int, parfois des double, selon la valeur.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>?;
    final weather = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};

    // Les timestamps sunrise/sunset sont en secondes Unix -> *1000 pour les
    // millisecondes attendues par DateTime.fromMillisecondsSinceEpoch.
    final sunriseTs = (sys['sunrise'] as num?)?.toInt() ?? 0;
    final sunsetTs = (sys['sunset'] as num?)?.toInt() ?? 0;

    return WeatherModel(
      cityName: json['name'] as String? ?? 'Inconnue',
      country: sys['country'] as String? ?? '--',
      temperature: ((main['temp'] as num?) ?? 0).toDouble(),
      feelsLike: ((main['feels_like'] as num?) ?? 0).toDouble(),
      tempMin: ((main['temp_min'] as num?) ?? 0).toDouble(),
      tempMax: ((main['temp_max'] as num?) ?? 0).toDouble(),
      humidity: ((main['humidity'] as num?) ?? 0).toInt(),
      pressure: ((main['pressure'] as num?) ?? 0).toInt(),
      windSpeed: ((wind['speed'] as num?) ?? 0).toDouble(),
      windDegree: ((wind['deg'] as num?) ?? 0).toInt(),
      description: weather['description'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '01d',
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      sunrise: DateTime.fromMillisecondsSinceEpoch(sunriseTs * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(sunsetTs * 1000),
    );
  }
}
