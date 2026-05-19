import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Batch Audio Birding'**
  String get appName;

  /// Splash: downloading model
  ///
  /// In en, this message translates to:
  /// **'Downloading AI model...'**
  String get splashDownloadingModel;

  /// No description provided for @splashModelReady.
  ///
  /// In en, this message translates to:
  /// **'Model ready'**
  String get splashModelReady;

  /// No description provided for @splashDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Download error. Check your connection.'**
  String get splashDownloadError;

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get splashRetry;

  /// No description provided for @splashDownloadProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% — {speed}'**
  String splashDownloadProgress(String percent, String speed);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch Audio Birding'**
  String get homeTitle;

  /// No description provided for @homeSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Audio Files'**
  String get homeSelectFolder;

  /// No description provided for @homeSelectFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more audio files to analyze'**
  String get homeSelectFolderSubtitle;

  /// No description provided for @homeLastFolder.
  ///
  /// In en, this message translates to:
  /// **'Last selection: {path}'**
  String homeLastFolder(String path);

  /// No description provided for @homeNoLastFolder.
  ///
  /// In en, this message translates to:
  /// **'No files selected'**
  String get homeNoLastFolder;

  /// No description provided for @homeFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} files selected'**
  String homeFilesSelected(int count);

  /// No description provided for @homeStartAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis'**
  String get homeStartAnalysis;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeFilterMode.
  ///
  /// In en, this message translates to:
  /// **'Filter mode'**
  String get homeFilterMode;

  /// No description provided for @homeThreshold.
  ///
  /// In en, this message translates to:
  /// **'Confidence threshold'**
  String get homeThreshold;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTitle;

  /// No description provided for @analysisProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} files'**
  String analysisProgress(int done, int total);

  /// No description provided for @analysisDetections.
  ///
  /// In en, this message translates to:
  /// **'{count} detections'**
  String analysisDetections(int count);

  /// No description provided for @analysisStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get analysisStop;

  /// No description provided for @analysisExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get analysisExportCsv;

  /// No description provided for @analysisStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get analysisStatusWaiting;

  /// No description provided for @analysisStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analysisStatusProcessing;

  /// No description provided for @analysisStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done — {count} detections'**
  String analysisStatusDone(int count);

  /// No description provided for @analysisStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String analysisStatusError(String message);

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get analysisComplete;

  /// No description provided for @analysisTotalAudio.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {min}m of audio'**
  String analysisTotalAudio(int hours, int min);

  /// No description provided for @analysisSpeciesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} species detected'**
  String analysisSpeciesFound(int count);

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTitle;

  /// No description provided for @resultsNoDetections.
  ///
  /// In en, this message translates to:
  /// **'No detections found'**
  String get resultsNoDetections;

  /// No description provided for @resultsFilterThreshold.
  ///
  /// In en, this message translates to:
  /// **'Minimum confidence'**
  String get resultsFilterThreshold;

  /// No description provided for @resultsExportFile.
  ///
  /// In en, this message translates to:
  /// **'Export this file'**
  String get resultsExportFile;

  /// No description provided for @resultsTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} — {end}'**
  String resultsTimeRange(String start, String end);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThreshold.
  ///
  /// In en, this message translates to:
  /// **'Confidence threshold'**
  String get settingsThreshold;

  /// No description provided for @settingsThresholdHelp.
  ///
  /// In en, this message translates to:
  /// **'Minimum confidence to show a detection (0.1 = 10%)'**
  String get settingsThresholdHelp;

  /// No description provided for @settingsOverlap.
  ///
  /// In en, this message translates to:
  /// **'Segment overlap (seconds)'**
  String get settingsOverlap;

  /// No description provided for @settingsOverlapHelp.
  ///
  /// In en, this message translates to:
  /// **'Overlap between 3-second audio windows (0–2.9s)'**
  String get settingsOverlapHelp;

  /// No description provided for @settingsFilterMode.
  ///
  /// In en, this message translates to:
  /// **'Species filter'**
  String get settingsFilterMode;

  /// No description provided for @settingsFilterNone.
  ///
  /// In en, this message translates to:
  /// **'No filter'**
  String get settingsFilterNone;

  /// No description provided for @settingsFilterGeo.
  ///
  /// In en, this message translates to:
  /// **'Geographic filter (GPS + week)'**
  String get settingsFilterGeo;

  /// No description provided for @settingsFilterList.
  ///
  /// In en, this message translates to:
  /// **'Custom species list'**
  String get settingsFilterList;

  /// No description provided for @settingsGeoLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get settingsGeoLatitude;

  /// No description provided for @settingsGeoLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get settingsGeoLongitude;

  /// No description provided for @settingsGeoWeek.
  ///
  /// In en, this message translates to:
  /// **'Week of year (1–48)'**
  String get settingsGeoWeek;

  /// No description provided for @settingsGeoUseGps.
  ///
  /// In en, this message translates to:
  /// **'Use device GPS'**
  String get settingsGeoUseGps;

  /// No description provided for @settingsSpeciesListPick.
  ///
  /// In en, this message translates to:
  /// **'Select species list file'**
  String get settingsSpeciesListPick;

  /// No description provided for @settingsSpeciesListNone.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get settingsSpeciesListNone;

  /// No description provided for @settingsSpeciesListSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} species loaded'**
  String settingsSpeciesListSelected(int count);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @errorPermissionStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required to read audio files'**
  String get errorPermissionStorage;

  /// No description provided for @errorPermissionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location permission required for geographic filter'**
  String get errorPermissionLocation;

  /// No description provided for @errorUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported audio format'**
  String get errorUnsupportedFormat;

  /// No description provided for @errorNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No audio files found in the selected folder'**
  String get errorNoFiles;

  /// No description provided for @errorModelNotFound.
  ///
  /// In en, this message translates to:
  /// **'AI model not found. Please restart the app.'**
  String get errorModelNotFound;

  /// No description provided for @csvExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'CSV exported successfully'**
  String get csvExportSuccess;

  /// No description provided for @csvExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting CSV'**
  String get csvExportError;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @preparingFiles.
  ///
  /// In en, this message translates to:
  /// **'Preparing files...'**
  String get preparingFiles;

  /// No description provided for @preparingFilesProgress.
  ///
  /// In en, this message translates to:
  /// **'Processing file {current} of {total}'**
  String preparingFilesProgress(int current, int total);

  /// No description provided for @homeViewSelectedFiles.
  ///
  /// In en, this message translates to:
  /// **'View selected files'**
  String get homeViewSelectedFiles;

  /// No description provided for @selectedFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected Files'**
  String get selectedFilesTitle;

  /// No description provided for @selectedFilesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get selectedFilesRemove;

  /// No description provided for @detailModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Detection Detail'**
  String get detailModalTitle;

  /// No description provided for @detailExportAudio.
  ///
  /// In en, this message translates to:
  /// **'Export Audio'**
  String get detailExportAudio;

  /// No description provided for @detailExportSpectrogram.
  ///
  /// In en, this message translates to:
  /// **'Export Spectrogram'**
  String get detailExportSpectrogram;

  /// No description provided for @detailLoopAudio.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get detailLoopAudio;

  /// No description provided for @detailSpectrogramLoading.
  ///
  /// In en, this message translates to:
  /// **'Generating spectrogram...'**
  String get detailSpectrogramLoading;

  /// No description provided for @detailSpectrogramFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Tap to expand'**
  String get detailSpectrogramFullscreen;

  /// No description provided for @audioExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Audio exported successfully to device'**
  String get audioExportSuccess;

  /// No description provided for @audioExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting audio'**
  String get audioExportError;

  /// No description provided for @spectrogramExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Spectrogram exported successfully to device'**
  String get spectrogramExportSuccess;

  /// No description provided for @spectrogramExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting spectrogram'**
  String get spectrogramExportError;

  /// No description provided for @settingsSensitivity.
  ///
  /// In en, this message translates to:
  /// **'AI Model Sensitivity'**
  String get settingsSensitivity;

  /// No description provided for @settingsSensitivityHelp.
  ///
  /// In en, this message translates to:
  /// **'Adjusts model sensitivity (0.5 = conservative, 1.5 = highly sensitive, default 1.0)'**
  String get settingsSensitivityHelp;

  /// No description provided for @settingsLocationThreshold.
  ///
  /// In en, this message translates to:
  /// **'Geographic Filter Threshold'**
  String get settingsLocationThreshold;

  /// No description provided for @settingsLocationThresholdHelp.
  ///
  /// In en, this message translates to:
  /// **'Minimum geographic probability threshold to include a species (default 0.03 = 3%)'**
  String get settingsLocationThresholdHelp;

  /// No description provided for @settingsGeoPreviewAllowedSpecies.
  ///
  /// In en, this message translates to:
  /// **'Preview Probable Species'**
  String get settingsGeoPreviewAllowedSpecies;

  /// No description provided for @previewAllowedSpeciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Probable Species'**
  String get previewAllowedSpeciesTitle;

  /// No description provided for @previewAllowedSpeciesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search species...'**
  String get previewAllowedSpeciesSearch;

  /// No description provided for @previewAllowedSpeciesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading probable species...'**
  String get previewAllowedSpeciesLoading;

  /// No description provided for @previewAllowedSpeciesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No species meet the filter criteria'**
  String get previewAllowedSpeciesEmpty;

  /// No description provided for @settingsSpectrogramTheme.
  ///
  /// In en, this message translates to:
  /// **'Spectrogram color scheme'**
  String get settingsSpectrogramTheme;

  /// No description provided for @settingsSpectrogramThemeHelp.
  ///
  /// In en, this message translates to:
  /// **'Select the color palette for the generated spectrograms'**
  String get settingsSpectrogramThemeHelp;

  /// No description provided for @settingsSpectrogramThemeGrayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get settingsSpectrogramThemeGrayscale;

  /// No description provided for @settingsSpectrogramThemeColored.
  ///
  /// In en, this message translates to:
  /// **'Colored'**
  String get settingsSpectrogramThemeColored;

  /// No description provided for @settingsSpeciesListsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Species Lists'**
  String get settingsSpeciesListsManage;

  /// No description provided for @customListsTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Species Lists'**
  String get customListsTitle;

  /// No description provided for @customListsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get customListsCreate;

  /// No description provided for @customListsImport.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get customListsImport;

  /// No description provided for @customListsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Species List'**
  String get customListsEdit;

  /// No description provided for @customListsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get customListsDelete;

  /// No description provided for @customListsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List Name'**
  String get customListsNameLabel;

  /// No description provided for @customListsNameError.
  ///
  /// In en, this message translates to:
  /// **'List name cannot be empty'**
  String get customListsNameError;

  /// No description provided for @customListsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list?'**
  String get customListsDeleteConfirm;

  /// No description provided for @customListsAddSpecies.
  ///
  /// In en, this message translates to:
  /// **'Add/Remove Species'**
  String get customListsAddSpecies;

  /// No description provided for @customListsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search species by name...'**
  String get customListsSearchPlaceholder;

  /// No description provided for @customListsNoLists.
  ///
  /// In en, this message translates to:
  /// **'No custom species lists created yet.'**
  String get customListsNoLists;

  /// No description provided for @customListsActive.
  ///
  /// In en, this message translates to:
  /// **'Active Filter'**
  String get customListsActive;

  /// No description provided for @customListsUseAsFilter.
  ///
  /// In en, this message translates to:
  /// **'Use as Filter'**
  String get customListsUseAsFilter;

  /// No description provided for @customListsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported successfully with {count} species!'**
  String customListsImportSuccess(int count);

  /// No description provided for @customListsImportHint.
  ///
  /// In en, this message translates to:
  /// **'Select a text file (.txt) containing one species per line.'**
  String get customListsImportHint;

  /// No description provided for @customListsOnlySelected.
  ///
  /// In en, this message translates to:
  /// **'Selected species'**
  String get customListsOnlySelected;

  /// No description provided for @customListsExport.
  ///
  /// In en, this message translates to:
  /// **'Export List'**
  String get customListsExport;

  /// No description provided for @customListsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'List exported successfully!'**
  String get customListsExportSuccess;

  /// No description provided for @customListsExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting species list'**
  String get customListsExportError;

  /// No description provided for @customListsExportEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Cannot export an empty species list'**
  String get customListsExportEmptyError;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Analyze batch audio recordings to automatically detect and identify bird species present in your soundscapes.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'AI Audio Analysis'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Powered by BirdNET AI, visualize detailed spectrograms and listen to detections dynamically synced with the audio.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Smart Filtering'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Reduce false positives using GPS-based geographic filters or create custom species lists tailored to your needs.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Ready to Explore'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'Select a folder containing your audio recordings and start your first acoustic batch analysis now!'**
  String get onboardingDesc4;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeModeHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose between a clean light theme, dark mode, or follow your system settings.'**
  String get settingsThemeModeHelp;

  /// No description provided for @settingsUpdateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Updates'**
  String get settingsUpdateSectionTitle;

  /// No description provided for @settingsUpdateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version'**
  String get settingsUpdateCurrentVersion;

  /// No description provided for @settingsUpdateUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Update Check Server URL (JSON)'**
  String get settingsUpdateUrlLabel;

  /// No description provided for @settingsUpdateCheckButton.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get settingsUpdateCheckButton;

  /// No description provided for @settingsUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Version Available!'**
  String get settingsUpdateTitle;

  /// No description provided for @settingsUpdateChangelogHeader.
  ///
  /// In en, this message translates to:
  /// **'Release Notes:'**
  String get settingsUpdateChangelogHeader;

  /// No description provided for @settingsUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get settingsUpdateLater;

  /// No description provided for @settingsUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get settingsUpdateNow;

  /// No description provided for @settingsUpdateLatestTitle.
  ///
  /// In en, this message translates to:
  /// **'Up to Date!'**
  String get settingsUpdateLatestTitle;

  /// No description provided for @settingsUpdateLatestDesc.
  ///
  /// In en, this message translates to:
  /// **'You are already running the latest version of the application.'**
  String get settingsUpdateLatestDesc;

  /// No description provided for @settingsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates'**
  String get settingsUpdateError;

  /// No description provided for @settingsUpdateNoChangelog.
  ///
  /// In en, this message translates to:
  /// **'No release notes provided.'**
  String get settingsUpdateNoChangelog;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
