# Application Météo — Activité n°4 (Accès à l'API OpenWeather)

Application Flutter développée selon l'architecture **MVC + Provider**,
conformément à la consigne de l'Atelier n°4.

## Structure du projet

```
lib/
├── main.dart                          # Point d'entrée + injection Provider
├── models/
│   └── weather_model.dart             # Modèle (M) : parsing JSON -> WeatherModel
├── services/
│   └── weather_service.dart           # Appels HTTP vers l'API OpenWeather
├── controllers/
│   └── weather_controller.dart        # Contrôleur (C) : ChangeNotifier, WeatherStatus
├── views/
│   └── weather_view.dart              # Vue (V) : interface + animations
├── widgets/
│   └── weather_widgets.dart           # Composants réutilisables
└── utils/
    └── weather_utils.dart             # Formatage (dates, températures, couleurs...)
```

## Installation et exécution

```bash
# 1. Créer le projet (si vous repartez de zéro) ou copier ces fichiers
#    dans un projet `flutter create activite_acces_api`

# 2. Installer les dépendances
flutter pub get

# 3. Ajouter la permission Internet (Android uniquement)
#    Voir android/app/src/main/AndroidManifest_extrait.xml

# 4. Renseigner votre clé API OpenWeather
#    Fichier : lib/services/weather_service.dart
#    Remplacer 'VOTRE_CLE_API_ICI' par votre clé réelle

# 5. Lancer l'application
flutter run
```

---

## ⚠️ Points à compléter / vérifier avant la remise

Ce projet couvre l'intégralité de la consigne (modèle, service, contrôleur,
vue, widgets, utils, animations), mais **certains éléments dépendent de
votre environnement personnel** et doivent impérativement être complétés
avant le rendu :

### 1. Clé API OpenWeather (obligatoire)
- Ouvrir `lib/services/weather_service.dart`
- Remplacer `VOTRE_CLE_API_ICI` par votre clé personnelle obtenue sur
  https://openweathermap.org/
- ⏳ La clé met **quelques heures** à devenir active après création : testez
  bien en avance.
- 🔒 Pour un vrai projet, il est recommandé de ne **jamais committer** la
  clé en clair (utiliser `--dart-define` ou un fichier `.env` ignoré par
  git). Pour cette activité pédagogique, la constante en dur est acceptable
  mais peut être signalée comme amélioration possible dans le rapport.

### 2. Permission Internet Android (obligatoire pour tester sur Android)
- Le fichier `android/` n'est généré qu'après `flutter create`. Une fois
  votre projet créé, ajoutez la ligne fournie dans
  `android/app/src/main/AndroidManifest_extrait.xml` à votre vrai
  `AndroidManifest.xml`.

### 3. Génération du projet complet
- Ce livrable contient uniquement les fichiers **`lib/`**, `pubspec.yaml`
  et un extrait Android. Il faut lancer `flutter create .` (ou créer un
  nouveau projet et y copier ces fichiers) pour obtenir l'arborescence
  complète (android/, ios/, web/, tests, icônes par défaut, etc.).

### 4. Tests à réaliser vous-même (demandés dans la consigne)
- ✅ Recherche d'une ville valide (ex : Paris, Dakar, Thiès)
- ✅ Ville inexistante → doit afficher le message 404
- ✅ Clé API invalide/absente → doit afficher le message 401
- ✅ Coupure réseau (mode avion) → doit afficher le message d'erreur réseau
- ✅ Vérifier que l'historique (chips) se met bien à jour et limite à 5 villes
- ✅ Vérifier la fluidité des animations (dégradé + fondu) sur un appareil réel

### 5. Éléments à personnaliser / améliorer selon la grille d'évaluation
- **Icônes et splash screen** : non générés ici (valeurs par défaut de
  `flutter create`), à personnaliser si vous voulez soigner la présentation.
- **Tests unitaires** : aucun test automatisé n'est fourni ; la grille
  mentionne "Tests, propreté du code" — pensez à ajouter au moins un test
  simple sur `WeatherModel.fromJson()` et `WeatherUtils`.
- **Rapport Word/PDF** : ce livrable est uniquement le code source. Le
  rapport de remise (captures d'écran, explications des choix
  d'architecture, difficultés rencontrées) reste à rédiger.
- **Gestion avancée du cache/offline** : non implémentée, hors périmètre de
  la consigne mais peut être mentionnée comme piste d'amélioration.
- **flutter_animate** : le package est déclaré dans `pubspec.yaml` comme
  demandé, mais les animations ont été implémentées avec les widgets
  natifs Flutter (`AnimatedContainer`, `FadeTransition`,
  `AnimationController`) pour rester alignées avec le cours. Vous pouvez
  enrichir certaines transitions avec la syntaxe `.animate()` de
  `flutter_animate` si vous souhaitez exploiter davantage ce package.

### 6. Vérification finale (checklist de la consigne)
- [ ] Le projet se lance sans erreur (`flutter run`)
- [ ] `WeatherModel` parse correctement le JSON réel de l'API
- [ ] Le service gère bien les codes 401 / 404 / 429 / erreur réseau
- [ ] Le contrôleur expose bien les 4 états via Provider
- [ ] La vue gère `initial`, `loading`, `success`, `error`
- [ ] Les widgets sont bien factorisés dans `weather_widgets.dart`
- [ ] Les animations (dégradé + fondu) sont visibles et fluides
- [ ] Le zip final + rapport Word/PDF sont prêts pour la remise
