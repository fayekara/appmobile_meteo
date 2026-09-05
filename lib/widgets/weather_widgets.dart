import 'package:flutter/material.dart';

/// Petite carte affichant un détail météo (humidité, vent, pression...)
/// dans la grille de la section "détails".
class WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const WeatherDetailCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Barre de recherche stylisée + chips d'historique des recherches
/// précédentes. StatefulWidget car elle gère son propre TextEditingController
/// si aucun n'est fourni... ici on impose de le passer depuis la vue pour
/// pouvoir lire/écrire la valeur depuis l'extérieur si besoin.
class WeatherSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final List<String> suggestions;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.suggestions = const [],
  });

  @override
  State<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends State<WeatherSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: widget.onSearch,
          decoration: InputDecoration(
            hintText: 'Entrez le nom d\'une ville...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () => setState(() => widget.controller.clear()),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.suggestions.map((ville) {
              return ActionChip(
                label: Text( ville),
                backgroundColor: Colors.white.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.green),
                onPressed: () {
                  widget.controller.text = ville;
                  widget.onSearch(ville);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Affiché quand aucune recherche n'a encore été effectuée (WeatherStatus.initial).
class WeatherInitialWidget extends StatelessWidget {
  const WeatherInitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.public, size: 90, color: Colors.white70),
        const SizedBox(height: 16),
        Text(
          'Recherchez une ville',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
        Text(
          'pour obtenir la météo en temps réel',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
      ],
    );
  }
}

/// Affiché pendant le chargement (WeatherStatus.loading).
class WeatherLoadingWidget extends StatelessWidget {
  const WeatherLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text(
          'Récupération de la météo...',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

/// Affiché en cas d'erreur (WeatherStatus.error), avec bouton Réessayer.
class WeatherErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WeatherErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 70, color: Colors.white),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }
}
