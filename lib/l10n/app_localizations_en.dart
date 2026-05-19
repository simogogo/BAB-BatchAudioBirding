// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Batch Audio Birding';

  @override
  String get splashDownloadingModel => 'Downloading AI model...';

  @override
  String get splashModelReady => 'Model ready';

  @override
  String get splashDownloadError => 'Download error. Check your connection.';

  @override
  String get splashRetry => 'Retry';

  @override
  String splashDownloadProgress(String percent, String speed) {
    return '$percent% — $speed';
  }

  @override
  String get homeTitle => 'Batch Audio Birding';

  @override
  String get homeSelectFolder => 'Select Audio Files';

  @override
  String get homeSelectFolderSubtitle =>
      'Choose one or more audio files to analyze';

  @override
  String homeLastFolder(String path) {
    return 'Last selection: $path';
  }

  @override
  String get homeNoLastFolder => 'No files selected';

  @override
  String homeFilesSelected(int count) {
    return '$count files selected';
  }

  @override
  String get homeStartAnalysis => 'Start Analysis';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeFilterMode => 'Filter mode';

  @override
  String get homeThreshold => 'Confidence threshold';

  @override
  String get analysisTitle => 'Analysis';

  @override
  String analysisProgress(int done, int total) {
    return '$done / $total files';
  }

  @override
  String analysisDetections(int count) {
    return '$count detections';
  }

  @override
  String get analysisStop => 'Stop';

  @override
  String get analysisExportCsv => 'Export CSV';

  @override
  String get analysisStatusWaiting => 'Waiting...';

  @override
  String get analysisStatusProcessing => 'Analyzing...';

  @override
  String analysisStatusDone(int count) {
    return 'Done — $count detections';
  }

  @override
  String analysisStatusError(String message) {
    return 'Error: $message';
  }

  @override
  String get analysisComplete => 'Analysis complete';

  @override
  String analysisTotalAudio(int hours, int min) {
    return '${hours}h ${min}m of audio';
  }

  @override
  String analysisSpeciesFound(int count) {
    return '$count species detected';
  }

  @override
  String get resultsTitle => 'Results';

  @override
  String get resultsNoDetections => 'No detections found';

  @override
  String get resultsFilterThreshold => 'Minimum confidence';

  @override
  String get resultsExportFile => 'Export this file';

  @override
  String resultsTimeRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThreshold => 'Confidence threshold';

  @override
  String get settingsThresholdHelp =>
      'Minimum confidence to show a detection (0.1 = 10%)';

  @override
  String get settingsOverlap => 'Segment overlap (seconds)';

  @override
  String get settingsOverlapHelp =>
      'Overlap between 3-second audio windows (0–2.9s)';

  @override
  String get settingsFilterMode => 'Species filter';

  @override
  String get settingsFilterNone => 'No filter';

  @override
  String get settingsFilterGeo => 'Geographic filter (GPS + week)';

  @override
  String get settingsFilterList => 'Custom species list';

  @override
  String get settingsGeoLatitude => 'Latitude';

  @override
  String get settingsGeoLongitude => 'Longitude';

  @override
  String get settingsGeoWeek => 'Week of year (1–48)';

  @override
  String get settingsGeoUseGps => 'Use device GPS';

  @override
  String get settingsSpeciesListPick => 'Select species list file';

  @override
  String get settingsSpeciesListNone => 'No file selected';

  @override
  String settingsSpeciesListSelected(int count) {
    return '$count species loaded';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSave => 'Save';

  @override
  String get errorPermissionStorage =>
      'Storage permission required to read audio files';

  @override
  String get errorPermissionLocation =>
      'Location permission required for geographic filter';

  @override
  String get errorUnsupportedFormat => 'Unsupported audio format';

  @override
  String get errorNoFiles => 'No audio files found in the selected folder';

  @override
  String get errorModelNotFound =>
      'AI model not found. Please restart the app.';

  @override
  String get csvExportSuccess => 'CSV exported successfully';

  @override
  String get csvExportError => 'Error exporting CSV';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get preparingFiles => 'Preparing files...';

  @override
  String preparingFilesProgress(int current, int total) {
    return 'Processing file $current of $total';
  }

  @override
  String get homeViewSelectedFiles => 'View selected files';

  @override
  String get selectedFilesTitle => 'Selected Files';

  @override
  String get selectedFilesRemove => 'Remove';

  @override
  String get detailModalTitle => 'Detection Detail';

  @override
  String get detailExportAudio => 'Export Audio';

  @override
  String get detailExportSpectrogram => 'Export Spectrogram';

  @override
  String get detailLoopAudio => 'Loop';

  @override
  String get detailSpectrogramLoading => 'Generating spectrogram...';

  @override
  String get detailSpectrogramFullscreen => 'Tap to expand';

  @override
  String get audioExportSuccess => 'Audio exported successfully to device';

  @override
  String get audioExportError => 'Error exporting audio';

  @override
  String get spectrogramExportSuccess =>
      'Spectrogram exported successfully to device';

  @override
  String get spectrogramExportError => 'Error exporting spectrogram';

  @override
  String get settingsSensitivity => 'AI Model Sensitivity';

  @override
  String get settingsSensitivityHelp =>
      'Adjusts model sensitivity (0.5 = conservative, 1.5 = highly sensitive, default 1.0)';

  @override
  String get settingsLocationThreshold => 'Geographic Filter Threshold';

  @override
  String get settingsLocationThresholdHelp =>
      'Minimum geographic probability threshold to include a species (default 0.03 = 3%)';

  @override
  String get settingsGeoPreviewAllowedSpecies => 'Preview Probable Species';

  @override
  String get previewAllowedSpeciesTitle => 'Probable Species';

  @override
  String get previewAllowedSpeciesSearch => 'Search species...';

  @override
  String get previewAllowedSpeciesLoading => 'Loading probable species...';

  @override
  String get previewAllowedSpeciesEmpty =>
      'No species meet the filter criteria';

  @override
  String get settingsSpectrogramTheme => 'Spectrogram color scheme';

  @override
  String get settingsSpectrogramThemeHelp =>
      'Select the color palette for the generated spectrograms';

  @override
  String get settingsSpectrogramThemeGrayscale => 'Grayscale';

  @override
  String get settingsSpectrogramThemeColored => 'Colored';

  @override
  String get settingsSpeciesListsManage => 'Manage Species Lists';

  @override
  String get customListsTitle => 'Custom Species Lists';

  @override
  String get customListsCreate => 'Create List';

  @override
  String get customListsImport => 'Import from File';

  @override
  String get customListsEdit => 'Edit Species List';

  @override
  String get customListsDelete => 'Delete List';

  @override
  String get customListsNameLabel => 'List Name';

  @override
  String get customListsNameError => 'List name cannot be empty';

  @override
  String get customListsDeleteConfirm =>
      'Are you sure you want to delete this list?';

  @override
  String get customListsAddSpecies => 'Add/Remove Species';

  @override
  String get customListsSearchPlaceholder => 'Search species by name...';

  @override
  String get customListsNoLists => 'No custom species lists created yet.';

  @override
  String get customListsActive => 'Active Filter';

  @override
  String get customListsUseAsFilter => 'Use as Filter';

  @override
  String customListsImportSuccess(int count) {
    return 'Imported successfully with $count species!';
  }

  @override
  String get customListsImportHint =>
      'Select a text file (.txt) containing one species per line.';

  @override
  String get customListsOnlySelected => 'Selected species';

  @override
  String get customListsExport => 'Export List';

  @override
  String get customListsExportSuccess => 'List exported successfully!';

  @override
  String get customListsExportError => 'Error exporting species list';

  @override
  String get customListsExportEmptyError =>
      'Cannot export an empty species list';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingTitle1 => 'Welcome';

  @override
  String get onboardingDesc1 =>
      'Analyze batch audio recordings to automatically detect and identify bird species present in your soundscapes.';

  @override
  String get onboardingTitle2 => 'AI Audio Analysis';

  @override
  String get onboardingDesc2 =>
      'Powered by BirdNET AI, visualize detailed spectrograms and listen to detections dynamically synced with the audio.';

  @override
  String get onboardingTitle3 => 'Smart Filtering';

  @override
  String get onboardingDesc3 =>
      'Reduce false positives using GPS-based geographic filters or create custom species lists tailored to your needs.';

  @override
  String get onboardingTitle4 => 'Ready to Explore';

  @override
  String get onboardingDesc4 =>
      'Select a folder containing your audio recordings and start your first acoustic batch analysis now!';

  @override
  String get settingsThemeMode => 'App Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeModeHelp =>
      'Choose between a clean light theme, dark mode, or follow your system settings.';

  @override
  String get settingsUpdateSectionTitle => 'Application Updates';

  @override
  String get settingsUpdateCurrentVersion => 'Current Version';

  @override
  String get settingsUpdateUrlLabel => 'Update Check Server URL (JSON)';

  @override
  String get settingsUpdateCheckButton => 'Check for Updates';

  @override
  String get settingsUpdateTitle => 'New Version Available!';

  @override
  String get settingsUpdateChangelogHeader => 'Release Notes:';

  @override
  String get settingsUpdateLater => 'Later';

  @override
  String get settingsUpdateNow => 'Update Now';

  @override
  String get settingsUpdateLatestTitle => 'Up to Date!';

  @override
  String get settingsUpdateLatestDesc =>
      'You are already running the latest version of the application.';

  @override
  String get settingsUpdateError => 'Failed to check for updates';

  @override
  String get settingsUpdateNoChangelog => 'No release notes provided.';
}
