// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Batch Audio Birding';

  @override
  String get splashDownloadingModel => 'KI-Modell wird heruntergeladen...';

  @override
  String get splashModelReady => 'Modell bereit';

  @override
  String get splashDownloadError =>
      'Download-Fehler. Überprüfe deine Verbindung.';

  @override
  String get splashRetry => 'Erneut versuchen';

  @override
  String splashDownloadProgress(String percent, String speed) {
    return '$percent% — $speed';
  }

  @override
  String get homeTitle => 'Batch Audio Birding';

  @override
  String get homeSelectFolder => 'Ordner auswählen';

  @override
  String get homeSelectFolderSubtitle =>
      'Wähle einen Ordner mit Audioaufnahmen';

  @override
  String homeLastFolder(String path) {
    return 'Letzter Ordner: $path';
  }

  @override
  String get homeNoLastFolder => 'Kein Ordner ausgewählt';

  @override
  String homeFilesSelected(int count) {
    return '$count Dateien ausgewählt';
  }

  @override
  String get homeStartAnalysis => 'Analyse starten';

  @override
  String get homeSettings => 'Einstellungen';

  @override
  String get homeFilterMode => 'Filtermodus';

  @override
  String get homeThreshold => 'Konfidenzschwelle';

  @override
  String get analysisTitle => 'Analyse';

  @override
  String analysisProgress(int done, int total) {
    return '$done / $total Dateien';
  }

  @override
  String analysisDetections(int count) {
    return '$count Erkennungen';
  }

  @override
  String get analysisStop => 'Stopp';

  @override
  String get analysisExportCsv => 'CSV exportieren';

  @override
  String get analysisStatusWaiting => 'Warten...';

  @override
  String get analysisStatusProcessing => 'Wird analysiert...';

  @override
  String analysisStatusDone(int count) {
    return 'Abgeschlossen — $count Erkennungen';
  }

  @override
  String analysisStatusError(String message) {
    return 'Fehler: $message';
  }

  @override
  String get analysisComplete => 'Analyse abgeschlossen';

  @override
  String analysisTotalAudio(int hours, int min) {
    return '${hours}h ${min}m Audio';
  }

  @override
  String analysisSpeciesFound(int count) {
    return '$count Arten erkannt';
  }

  @override
  String get resultsTitle => 'Ergebnisse';

  @override
  String get resultsNoDetections => 'Keine Erkennungen gefunden';

  @override
  String get resultsFilterThreshold => 'Mindestkonfidenz';

  @override
  String get resultsExportFile => 'Diese Datei exportieren';

  @override
  String resultsTimeRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsThreshold => 'Konfidenzschwelle';

  @override
  String get settingsThresholdHelp =>
      'Mindestkonfidenz zur Anzeige einer Erkennung (0.1 = 10%)';

  @override
  String get settingsOverlap => 'Segmentüberlappung (Sekunden)';

  @override
  String get settingsOverlapHelp =>
      'Überlappung zwischen 3-Sekunden-Audiofenstern (0–2.9s)';

  @override
  String get settingsFilterMode => 'Artenfilter';

  @override
  String get settingsFilterNone => 'Kein Filter';

  @override
  String get settingsFilterGeo => 'Geografischer Filter (GPS + Woche)';

  @override
  String get settingsFilterList => 'Benutzerdefinierte Artenliste';

  @override
  String get settingsGeoLatitude => 'Breitengrad';

  @override
  String get settingsGeoLongitude => 'Längengrad';

  @override
  String get settingsGeoWeek => 'Woche des Jahres (1–48)';

  @override
  String get settingsGeoUseGps => 'Geräte-GPS verwenden';

  @override
  String get settingsSpeciesListPick => 'Artenlisten-Datei auswählen';

  @override
  String get settingsSpeciesListNone => 'Keine Datei ausgewählt';

  @override
  String settingsSpeciesListSelected(int count) {
    return '$count Arten geladen';
  }

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSave => 'Speichern';

  @override
  String get errorPermissionStorage =>
      'Speicherberechtigung erforderlich zum Lesen von Audiodateien';

  @override
  String get errorPermissionLocation =>
      'Standortberechtigung für den geografischen Filter erforderlich';

  @override
  String get errorUnsupportedFormat => 'Nicht unterstütztes Audioformat';

  @override
  String get errorNoFiles =>
      'Keine Audiodateien im ausgewählten Ordner gefunden';

  @override
  String get errorModelNotFound =>
      'KI-Modell nicht gefunden. Bitte starte die App neu.';

  @override
  String get csvExportSuccess => 'CSV erfolgreich exportiert';

  @override
  String get csvExportError => 'Fehler beim CSV-Export';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Schließen';

  @override
  String get preparingFiles => 'Dateien werden vorbereitet...';

  @override
  String preparingFilesProgress(int current, int total) {
    return 'Datei $current von $total wird verarbeitet';
  }

  @override
  String get homeViewSelectedFiles => 'Ausgewählte Dateien anzeigen';

  @override
  String get selectedFilesTitle => 'Ausgewählte Dateien';

  @override
  String get selectedFilesRemove => 'Entfernen';

  @override
  String get detailModalTitle => 'Erkennungsdetails';

  @override
  String get detailExportAudio => 'Audio exportieren';

  @override
  String get detailExportSpectrogram => 'Spektrogramm exportieren';

  @override
  String get detailLoopAudio => 'Schleife';

  @override
  String get detailSpectrogramLoading => 'Spektrogramm wird generiert...';

  @override
  String get detailSpectrogramFullscreen => 'Zum Vergrößern tippen';

  @override
  String get audioExportSuccess => 'Audio erfolgreich auf das Gerät exportiert';

  @override
  String get audioExportError => 'Fehler beim Exportieren von Audio';

  @override
  String get spectrogramExportSuccess =>
      'Spektrogramm erfolgreich auf das Gerät exportiert';

  @override
  String get spectrogramExportError =>
      'Fehler beim Exportieren des Spektrogramms';

  @override
  String get settingsSensitivity => 'KI-Modellsensitivität';

  @override
  String get settingsSensitivityHelp =>
      'Passt die Modellsensitivität an (0.5 = konservativ, 1.5 = hochsensibel, Standard 1.0)';

  @override
  String get settingsLocationThreshold => 'Geografischer Filterschwellenwert';

  @override
  String get settingsLocationThresholdHelp =>
      'Mindestschwellenwert der geografischen Wahrscheinlichkeit, um eine Art einzuschließen (Standard 0.03 = 3%)';

  @override
  String get settingsGeoPreviewAllowedSpecies =>
      'Vorschau wahrscheinlicher Arten';

  @override
  String get previewAllowedSpeciesTitle => 'Wahrscheinliche Arten';

  @override
  String get previewAllowedSpeciesSearch => 'Arten suchen...';

  @override
  String get previewAllowedSpeciesLoading =>
      'Wahrscheinliche Arten werden geladen...';

  @override
  String get previewAllowedSpeciesEmpty =>
      'Keine Arten entsprechen den Filterkriterien';

  @override
  String get settingsSpectrogramTheme => 'Spektrogramm-Farbschema';

  @override
  String get settingsSpectrogramThemeHelp =>
      'Wähle die Farbpalette für die generierten Spektrogramme';

  @override
  String get settingsSpectrogramThemeGrayscale => 'Graustufen';

  @override
  String get settingsSpectrogramThemeColored => 'Farbig';

  @override
  String get settingsSpeciesListsManage => 'Artenlisten verwalten';

  @override
  String get customListsTitle => 'Benutzerdefinierte Artenlisten';

  @override
  String get customListsCreate => 'Liste erstellen';

  @override
  String get customListsImport => 'Aus Datei importieren';

  @override
  String get customListsEdit => 'Artenliste bearbeiten';

  @override
  String get customListsDelete => 'Liste löschen';

  @override
  String get customListsNameLabel => 'Listenname';

  @override
  String get customListsNameError => 'Listenname darf nicht leer sein';

  @override
  String get customListsDeleteConfirm =>
      'Sind Sie sicher, dass Sie diese Liste löschen möchten?';

  @override
  String get customListsAddSpecies => 'Arten hinzufügen/entfernen';

  @override
  String get customListsSearchPlaceholder => 'Arten nach Namen suchen...';

  @override
  String get customListsNoLists =>
      'Noch keine benutzerdefinierten Artenlisten erstellt.';

  @override
  String get customListsActive => 'Aktiver Filter';

  @override
  String get customListsUseAsFilter => 'Als Filter verwenden';

  @override
  String customListsImportSuccess(int count) {
    return 'Erfolgreich mit $count Arten importiert!';
  }

  @override
  String get customListsImportHint =>
      'Wähle eine Textdatei (.txt) mit einer Art pro Zeile.';

  @override
  String get customListsOnlySelected => 'Ausgewählte Arten';

  @override
  String get customListsExport => 'Liste exportieren';

  @override
  String get customListsExportSuccess => 'Liste erfolgreich exportiert!';

  @override
  String get customListsExportError => 'Fehler beim Exportieren der Artenliste';

  @override
  String get customListsExportEmptyError =>
      'Leere Artenliste kann nicht exportiert werden';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Starten';

  @override
  String get onboardingTitle1 => 'Willkommen';

  @override
  String get onboardingDesc1 =>
      'Analysieren Sie Audioaufnahmen im Batch, um vorhandene Vogelarten automatisch zu erkennen und zu identifizieren.';

  @override
  String get onboardingTitle2 => 'KI-Audioanalyse';

  @override
  String get onboardingDesc2 =>
      'Unterstützt durch BirdNET AI: Visualisieren Sie detaillierte Spektrogramme und hören Sie Erkennungen synchronisiert.';

  @override
  String get onboardingTitle3 => 'Intelligente Filterung';

  @override
  String get onboardingDesc3 =>
      'Reduzieren Sie Fehlalarme mithilfe von GPS-Filtern oder erstellen Sie benutzerdefinierte Artenlisten nach Bedarf.';

  @override
  String get onboardingTitle4 => 'Bereit zum Erkunden';

  @override
  String get onboardingDesc4 =>
      'Wählen Sie einen Ordner mit Ihren Audioaufnahmen aus und starten Sie jetzt Ihre erste akustische Batch-Analyse!';

  @override
  String get settingsThemeMode => 'App-Thema';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeModeHelp =>
      'Wählen Sie zwischen einem hellen Thema, einem dunklen Modus oder folgen Sie den Systemeinstellungen.';

  @override
  String get settingsUpdateSectionTitle => 'Anwendungs-Updates';

  @override
  String get settingsUpdateCurrentVersion => 'Aktuelle Version';

  @override
  String get settingsUpdateUrlLabel => 'Update-Server-URL (JSON)';

  @override
  String get settingsUpdateCheckButton => 'Nach Updates suchen';

  @override
  String get settingsUpdateTitle => 'Neue Version verfügbar!';

  @override
  String get settingsUpdateChangelogHeader => 'Versionshinweise:';

  @override
  String get settingsUpdateLater => 'Später';

  @override
  String get settingsUpdateNow => 'Jetzt aktualisieren';

  @override
  String get settingsUpdateLatestTitle => 'Auf dem neuesten Stand!';

  @override
  String get settingsUpdateLatestDesc =>
      'Sie führen bereits die neueste Version der Anwendung aus.';

  @override
  String get settingsUpdateError => 'Fehler beim Suchen nach Updates';

  @override
  String get settingsUpdateNoChangelog => 'Keine Versionshinweise angegeben.';
}
