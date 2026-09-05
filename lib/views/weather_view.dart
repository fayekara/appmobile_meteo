import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/weather_controller.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import '../widgets/weather_widgets.dart';

/// Vue principale de l'application météo. StatefulWidget car elle gère
/// l'AnimationController du fondu d'apparition (SingleTickerProviderStateMixin)
/// ainsi que le TextEditingController de la barre de recherche.
class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Couleurs du dégradé de fond ; mises à jour via setState() =>
  // animées automatiquement par l'AnimatedContainer (animation implicite).
  List<Color> _gradientColors = const [Colors.blue, Colors.lightBlueAccent];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _lancerRecherche(String ville) {
    if (ville.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<WeatherController>().fetchWeather(ville);
  }

  /// Appelé après réception des données pour mettre à jour le dégradé
  /// (animation implicite) et jouer le fondu d'apparition (animation explicite).
  void _onDonneesRecues(WeatherModel weather) {
    setState(() {
      _gradientColors = WeatherUtils.getGradientColors(weather.iconCode);
    });
    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherController>(
      builder: (context, controller, _) {
        // Déclenche l'animation d'apparition dès qu'on reçoit des données,
        // sans provoquer de setState pendant le build (post-frame callback).
        if (controller.hasData && controller.weather != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_fadeController.value == 0) {
              _onDonneesRecues(controller.weather!);
            }
          });
        }

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAppBar(controller),
                    const SizedBox(height: 12),
                    WeatherSearchBar(
                      controller: _searchController,
                      onSearch: _lancerRecherche,
                      suggestions: controller.searchHistory,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading
                            ? null
                            : () => _lancerRecherche(_searchController.text),
                        icon: const Icon(Icons.search),
                        label: const Text('Obtenir la météo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: _buildContent(controller)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(WeatherController controller) {
    return Row(
      children: [
        const Icon(Icons.wb_sunny, color: Colors.white),
        const SizedBox(width: 8),
        const Text(
          'Application MétéO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (controller.hasData)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.isLoading ? null : controller.retry,
          ),
      ],
    );
  }

  /// Affiche un widget différent selon l'état WeatherStatus courant.
  Widget _buildContent(WeatherController controller) {
    switch (controller.status) {
      case WeatherStatus.initial:
        return const WeatherInitialWidget();
      case WeatherStatus.loading:
        return const WeatherLoadingWidget();
      case WeatherStatus.error:
        return WeatherErrorWidget(
          message: controller.errorMessage,
          onRetry: () => _lancerRecherche(_searchController.text),
        );
      case WeatherStatus.success:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _WeatherDataView(weather: controller.weather!),
        );
    }
  }
}

/// Sous-vue affichant l'ensemble des données météo une fois reçues avec
/// succès : section principale, grille de détails, section lever/coucher.
class _WeatherDataView extends StatelessWidget {
  final WeatherModel weather;

  const _WeatherDataView({required this.weather});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSectionPrincipale(),
          const SizedBox(height: 20),
          _buildGrilleDetails(),
          const SizedBox(height: 20),
          _buildSectionSoleil(),
        ],
      ),
    );
  }

  Widget _buildSectionPrincipale() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                '${weather.cityName}, ${weather.country}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            WeatherUtils.capitalize(WeatherUtils.formatDate(DateTime.now())),
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            WeatherUtils.getWeatherEmoji(weather.iconCode),
            style: const TextStyle(fontSize: 56),
          ),
          Text(
            WeatherUtils.formatTemp(weather.temperature),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Ressenti ${WeatherUtils.formatTemp(weather.feelsLike)}',
            style: TextStyle(color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              WeatherUtils.capitalize(weather.description),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Min ${WeatherUtils.formatTemp(weather.tempMin)}',
                style: const TextStyle(color: Colors.lightBlueAccent),
              ),
              const SizedBox(width: 16),
              Text(
                'Max ${WeatherUtils.formatTemp(weather.tempMax)}',
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrilleDetails() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        WeatherDetailCard(
          icon: Icons.water_drop,
          label: 'Humidité',
          value: '${weather.humidity}%',
          iconColor: Colors.lightBlueAccent,
        ),
        WeatherDetailCard(
          icon: Icons.air,
          label: 'Vent',
          value: '${weather.windSpeed} m/s ${_directionVent(weather.windDegree)}',
          iconColor: Colors.white,
        ),
        WeatherDetailCard(
          icon: Icons.speed,
          label: 'Pression',
          value: '${weather.pressure} hPa',
          iconColor: Colors.purpleAccent,
        ),
        WeatherDetailCard(
          icon: Icons.visibility,
          label: 'Visibilité',
          value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
          iconColor: Colors.amberAccent,
        ),
      ],
    );
  }

  Widget _buildSectionSoleil() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.wb_twilight, color: Colors.orangeAccent),
              const SizedBox(height: 4),
              const Text('Lever', style: TextStyle(color: Colors.white70)),
              Text(
                WeatherUtils.formatTime(weather.sunrise),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.nights_stay, color: Colors.indigoAccent),
              const SizedBox(height: 4),
              const Text('Coucher', style: TextStyle(color: Colors.white70)),
              Text(
                WeatherUtils.formatTime(weather.sunset),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _directionVent(int degree) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((degree % 360) / 45).round() % 8;
    return directions[index];
  }
}
