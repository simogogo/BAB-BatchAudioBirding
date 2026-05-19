// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Batch Audio Birding';

  @override
  String get splashDownloadingModel => 'Téléchargement du modèle IA...';

  @override
  String get splashModelReady => 'Modèle prêt';

  @override
  String get splashDownloadError =>
      'Erreur de téléchargement. Vérifiez votre connexion.';

  @override
  String get splashRetry => 'Réessayer';

  @override
  String splashDownloadProgress(String percent, String speed) {
    return '$percent% — $speed';
  }

  @override
  String get homeTitle => 'Batch Audio Birding';

  @override
  String get homeSelectFolder => 'Sélectionner un Dossier';

  @override
  String get homeSelectFolderSubtitle =>
      'Choisissez un dossier contenant des enregistrements audio';

  @override
  String homeLastFolder(String path) {
    return 'Dernier dossier : $path';
  }

  @override
  String get homeNoLastFolder => 'Aucun dossier sélectionné';

  @override
  String homeFilesSelected(int count) {
    return '$count fichiers sélectionnés';
  }

  @override
  String get homeStartAnalysis => 'Démarrer l\'Analyse';

  @override
  String get homeSettings => 'Paramètres';

  @override
  String get homeFilterMode => 'Mode de filtre';

  @override
  String get homeThreshold => 'Seuil de confiance';

  @override
  String get analysisTitle => 'Analyse';

  @override
  String analysisProgress(int done, int total) {
    return '$done / $total fichiers';
  }

  @override
  String analysisDetections(int count) {
    return '$count détections';
  }

  @override
  String get analysisStop => 'Arrêter';

  @override
  String get analysisExportCsv => 'Exporter CSV';

  @override
  String get analysisStatusWaiting => 'En attente...';

  @override
  String get analysisStatusProcessing => 'Analyse en cours...';

  @override
  String analysisStatusDone(int count) {
    return 'Terminé — $count détections';
  }

  @override
  String analysisStatusError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get analysisComplete => 'Analyse terminée';

  @override
  String analysisTotalAudio(int hours, int min) {
    return '${hours}h ${min}m d\'audio';
  }

  @override
  String analysisSpeciesFound(int count) {
    return '$count espèces détectées';
  }

  @override
  String get resultsTitle => 'Résultats';

  @override
  String get resultsNoDetections => 'Aucune détection trouvée';

  @override
  String get resultsFilterThreshold => 'Confiance minimale';

  @override
  String get resultsExportFile => 'Exporter ce fichier';

  @override
  String resultsTimeRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsThreshold => 'Seuil de confiance';

  @override
  String get settingsThresholdHelp =>
      'Confiance minimale pour afficher une détection (0.1 = 10%)';

  @override
  String get settingsOverlap => 'Chevauchement des segments (secondes)';

  @override
  String get settingsOverlapHelp =>
      'Chevauchement entre les fenêtres audio de 3 secondes (0–2.9s)';

  @override
  String get settingsFilterMode => 'Filtre d\'espèces';

  @override
  String get settingsFilterNone => 'Aucun filtre';

  @override
  String get settingsFilterGeo => 'Filtre géographique (GPS + semaine)';

  @override
  String get settingsFilterList => 'Liste d\'espèces personnalisée';

  @override
  String get settingsGeoLatitude => 'Latitude';

  @override
  String get settingsGeoLongitude => 'Longitude';

  @override
  String get settingsGeoWeek => 'Semaine de l\'année (1–48)';

  @override
  String get settingsGeoUseGps => 'Utiliser le GPS de l\'appareil';

  @override
  String get settingsSpeciesListPick =>
      'Sélectionner le fichier de liste d\'espèces';

  @override
  String get settingsSpeciesListNone => 'Aucun fichier sélectionné';

  @override
  String settingsSpeciesListSelected(int count) {
    return '$count espèces chargées';
  }

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSave => 'Enregistrer';

  @override
  String get errorPermissionStorage =>
      'Permission de stockage requise pour lire les fichiers audio';

  @override
  String get errorPermissionLocation =>
      'Permission de localisation requise pour le filtre géographique';

  @override
  String get errorUnsupportedFormat => 'Format audio non supporté';

  @override
  String get errorNoFiles =>
      'Aucun fichier audio trouvé dans le dossier sélectionné';

  @override
  String get errorModelNotFound =>
      'Modèle IA introuvable. Veuillez redémarrer l\'application.';

  @override
  String get csvExportSuccess => 'CSV exporté avec succès';

  @override
  String get csvExportError => 'Erreur lors de l\'exportation CSV';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Fermer';

  @override
  String get preparingFiles => 'Préparation des fichiers...';

  @override
  String preparingFilesProgress(int current, int total) {
    return 'Traitement du fichier $current sur $total';
  }

  @override
  String get homeViewSelectedFiles => 'Voir les fichiers sélectionnés';

  @override
  String get selectedFilesTitle => 'Fichiers Sélectionnés';

  @override
  String get selectedFilesRemove => 'Supprimer';

  @override
  String get detailModalTitle => 'Détails de Détection';

  @override
  String get detailExportAudio => 'Exporter l\'audio';

  @override
  String get detailExportSpectrogram => 'Exporter le spectrogramme';

  @override
  String get detailLoopAudio => 'Boucle';

  @override
  String get detailSpectrogramLoading => 'Génération du spectrogramme...';

  @override
  String get detailSpectrogramFullscreen => 'Toucher pour agrandir';

  @override
  String get audioExportSuccess => 'Audio exporté avec succès vers l\'appareil';

  @override
  String get audioExportError => 'Erreur lors de l\'exportation de l\'audio';

  @override
  String get spectrogramExportSuccess =>
      'Spectrogramme exporté avec succès vers l\'appareil';

  @override
  String get spectrogramExportError =>
      'Erreur lors de l\'exportation du spectrogramme';

  @override
  String get settingsSensitivity => 'Sensibilité du modèle IA';

  @override
  String get settingsSensitivityHelp =>
      'Ajuste la sensibilité du modèle (0.5 = conservateur, 1.5 = très sensible, défaut 1.0)';

  @override
  String get settingsLocationThreshold => 'Seuil du filtre géographique';

  @override
  String get settingsLocationThresholdHelp =>
      'Seuil minimal de probabilité géographique pour inclure une espèce (défaut 0.03 = 3%)';

  @override
  String get settingsGeoPreviewAllowedSpecies => 'Aperçu des espèces probables';

  @override
  String get previewAllowedSpeciesTitle => 'Espèces Probables';

  @override
  String get previewAllowedSpeciesSearch => 'Rechercher des espèces...';

  @override
  String get previewAllowedSpeciesLoading =>
      'Chargement des espèces probables...';

  @override
  String get previewAllowedSpeciesEmpty =>
      'Aucune espèce ne correspond aux critères du filtre';

  @override
  String get settingsSpectrogramTheme => 'Palette de couleurs du spectrogramme';

  @override
  String get settingsSpectrogramThemeHelp =>
      'Sélectionnez la palette de couleurs pour les spectrogrammes générés';

  @override
  String get settingsSpectrogramThemeGrayscale => 'Échelle de gris';

  @override
  String get settingsSpectrogramThemeColored => 'Couleur';

  @override
  String get settingsSpeciesListsManage => 'Gérer les listes d\'espèces';

  @override
  String get customListsTitle => 'Listes d\'Espèces Personnalisées';

  @override
  String get customListsCreate => 'Créer une Liste';

  @override
  String get customListsImport => 'Importer depuis un Fichier';

  @override
  String get customListsEdit => 'Modifier la Liste d\'Espèces';

  @override
  String get customListsDelete => 'Supprimer la Liste';

  @override
  String get customListsNameLabel => 'Nom de la Liste';

  @override
  String get customListsNameError => 'Le nom de la liste ne peut pas être vide';

  @override
  String get customListsDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette liste ?';

  @override
  String get customListsAddSpecies => 'Ajouter/Supprimer des Espèces';

  @override
  String get customListsSearchPlaceholder =>
      'Rechercher des espèces par nom...';

  @override
  String get customListsNoLists =>
      'Aucune liste d\'espèces personnalisée créée pour le moment.';

  @override
  String get customListsActive => 'Filtre Actif';

  @override
  String get customListsUseAsFilter => 'Utiliser comme Filtre';

  @override
  String customListsImportSuccess(int count) {
    return 'Importé avec succès avec $count espèces !';
  }

  @override
  String get customListsImportHint =>
      'Sélectionnez un fichier texte (.txt) contenant une espèce par ligne.';

  @override
  String get customListsOnlySelected => 'Espèces sélectionnées';

  @override
  String get customListsExport => 'Exporter la Liste';

  @override
  String get customListsExportSuccess => 'Liste exportée avec succès !';

  @override
  String get customListsExportError =>
      'Erreur lors de l\'exportation de la liste';

  @override
  String get customListsExportEmptyError =>
      'Impossible d\'exporter une liste vide';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingTitle1 => 'Bienvenue';

  @override
  String get onboardingDesc1 =>
      'Analysez des enregistrements audio par lots pour détecter et identifier automatiquement les espèces d\'oiseaux présentes.';

  @override
  String get onboardingTitle2 => 'Analyse Audio IA';

  @override
  String get onboardingDesc2 =>
      'Propulsé par BirdNET AI, visualisez des spectrogrammes détaillés et écoutez les détections synchronisées avec l\'audio.';

  @override
  String get onboardingTitle3 => 'Filtrage Intelligent';

  @override
  String get onboardingDesc3 =>
      'Réduisez les faux positifs grâce aux filtres géographiques GPS ou créez des listes d\'espèces personnalisées.';

  @override
  String get onboardingTitle4 => 'Prêt à Explorer';

  @override
  String get onboardingDesc4 =>
      'Sélectionnez un dossier contenant vos enregistrements audio et commencez votre première analyse acoustique !';

  @override
  String get settingsThemeMode => 'Thème de l\'application';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeModeHelp =>
      'Choisissez entre un thème clair, sombre ou suivez les paramètres système.';

  @override
  String get settingsUpdateSectionTitle => 'Mises à jour de l\'application';

  @override
  String get settingsUpdateCurrentVersion => 'Version actuelle';

  @override
  String get settingsUpdateUrlLabel => 'URL du serveur de vérification (JSON)';

  @override
  String get settingsUpdateCheckButton => 'Vérifier les mises à jour';

  @override
  String get settingsUpdateTitle => 'Nouvelle version disponible !';

  @override
  String get settingsUpdateChangelogHeader => 'Notes de version :';

  @override
  String get settingsUpdateLater => 'Plus tard';

  @override
  String get settingsUpdateNow => 'Mettre à jour maintenant';

  @override
  String get settingsUpdateLatestTitle => 'À jour !';

  @override
  String get settingsUpdateLatestDesc =>
      'Vous utilisez déjà la dernière version de l\'application.';

  @override
  String get settingsUpdateError => 'Échec de la vérification des mises à jour';

  @override
  String get settingsUpdateNoChangelog => 'Aucune note de version fournie.';
}
