// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Batch Audio Birding';

  @override
  String get splashDownloadingModel => 'Download modello AI in corso...';

  @override
  String get splashModelReady => 'Modello pronto';

  @override
  String get splashDownloadError =>
      'Errore di download. Controlla la connessione.';

  @override
  String get splashRetry => 'Riprova';

  @override
  String splashDownloadProgress(String percent, String speed) {
    return '$percent% — $speed';
  }

  @override
  String get homeTitle => 'Batch Audio Birding';

  @override
  String get homeSelectFolder => 'Seleziona File Audio';

  @override
  String get homeSelectFolderSubtitle => 'Scegli uno o più file da analizzare';

  @override
  String homeLastFolder(String path) {
    return 'Ultima selezione: $path';
  }

  @override
  String get homeNoLastFolder => 'Nessun file selezionato';

  @override
  String homeFilesSelected(int count) {
    return '$count file selezionati';
  }

  @override
  String get homeStartAnalysis => 'Avvia Analisi';

  @override
  String get homeSettings => 'Impostazioni';

  @override
  String get homeFilterMode => 'Modalità filtro';

  @override
  String get homeThreshold => 'Soglia di confidenza';

  @override
  String get analysisTitle => 'Analisi';

  @override
  String analysisProgress(int done, int total) {
    return '$done / $total file';
  }

  @override
  String analysisDetections(int count) {
    return '$count rilevamenti';
  }

  @override
  String get analysisStop => 'Ferma';

  @override
  String get analysisExportCsv => 'Esporta CSV';

  @override
  String get analysisStatusWaiting => 'In attesa...';

  @override
  String get analysisStatusProcessing => 'Analisi in corso...';

  @override
  String analysisStatusDone(int count) {
    return 'Completato — $count rilevamenti';
  }

  @override
  String analysisStatusError(String message) {
    return 'Errore: $message';
  }

  @override
  String get analysisComplete => 'Analisi completata';

  @override
  String analysisTotalAudio(int hours, int min) {
    return '${hours}h ${min}m di audio';
  }

  @override
  String analysisSpeciesFound(int count) {
    return '$count specie rilevate';
  }

  @override
  String get resultsTitle => 'Risultati';

  @override
  String get resultsNoDetections => 'Nessun rilevamento trovato';

  @override
  String get resultsFilterThreshold => 'Confidenza minima';

  @override
  String get resultsExportFile => 'Esporta questo file';

  @override
  String resultsTimeRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsThreshold => 'Soglia di confidenza';

  @override
  String get settingsThresholdHelp =>
      'Confidenza minima per mostrare un rilevamento (0.1 = 10%)';

  @override
  String get settingsOverlap => 'Sovrapposizione segmenti (secondi)';

  @override
  String get settingsOverlapHelp =>
      'Sovrapposizione tra finestre audio da 3 secondi (0–2.9s)';

  @override
  String get settingsFilterMode => 'Filtro specie';

  @override
  String get settingsFilterNone => 'Nessun filtro';

  @override
  String get settingsFilterGeo => 'Filtro geografico (GPS + settimana)';

  @override
  String get settingsFilterList => 'Lista specie personalizzata';

  @override
  String get settingsGeoLatitude => 'Latitudine';

  @override
  String get settingsGeoLongitude => 'Longitudine';

  @override
  String get settingsGeoWeek => 'Settimana dell\'anno (1–48)';

  @override
  String get settingsGeoUseGps => 'Usa GPS del dispositivo';

  @override
  String get settingsSpeciesListPick => 'Seleziona file lista specie';

  @override
  String get settingsSpeciesListNone => 'Nessun file selezionato';

  @override
  String settingsSpeciesListSelected(int count) {
    return '$count specie caricate';
  }

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsSave => 'Salva';

  @override
  String get errorPermissionStorage =>
      'Permesso di archiviazione richiesto per leggere i file audio';

  @override
  String get errorPermissionLocation =>
      'Permesso posizione richiesto per il filtro geografico';

  @override
  String get errorUnsupportedFormat => 'Formato audio non supportato';

  @override
  String get errorNoFiles =>
      'Nessun file audio trovato nella cartella selezionata';

  @override
  String get errorModelNotFound => 'Modello AI non trovato. Riavvia l\'app.';

  @override
  String get csvExportSuccess => 'CSV esportato con successo';

  @override
  String get csvExportError => 'Errore durante l\'esportazione CSV';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get preparingFiles => 'Preparazione file...';

  @override
  String preparingFilesProgress(int current, int total) {
    return 'Elaborazione file $current di $total';
  }

  @override
  String get homeViewSelectedFiles => 'Vedi file selezionati';

  @override
  String get selectedFilesTitle => 'File Selezionati';

  @override
  String get selectedFilesRemove => 'Rimuovi';

  @override
  String get detailModalTitle => 'Dettaglio Rilevamento';

  @override
  String get detailExportAudio => 'Esporta Audio';

  @override
  String get detailExportSpectrogram => 'Esporta Sonogramma';

  @override
  String get detailLoopAudio => 'Ripeti';

  @override
  String get detailSpectrogramLoading => 'Generazione sonogramma...';

  @override
  String get detailSpectrogramFullscreen => 'Tocca per ingrandire';

  @override
  String get audioExportSuccess =>
      'Audio esportato con successo nel dispositivo';

  @override
  String get audioExportError => 'Errore durante l\'esportazione audio';

  @override
  String get spectrogramExportSuccess =>
      'Sonogramma esportato con successo nel dispositivo';

  @override
  String get spectrogramExportError =>
      'Errore durante l\'esportazione sonogramma';

  @override
  String get settingsSensitivity => 'Sensibilità modello AI';

  @override
  String get settingsSensitivityHelp =>
      'Regola la sensibilità del modello (0.5 = conservativa, 1.5 = molto sensibile, default 1.0)';

  @override
  String get settingsLocationThreshold => 'Soglia filtro geografico';

  @override
  String get settingsLocationThresholdHelp =>
      'Soglia minima di probabilità geografica per includere una specie (default 0.03 = 3%)';

  @override
  String get settingsGeoPreviewAllowedSpecies => 'Anteprima specie probabili';

  @override
  String get previewAllowedSpeciesTitle => 'Specie Probabili';

  @override
  String get previewAllowedSpeciesSearch => 'Cerca specie...';

  @override
  String get previewAllowedSpeciesLoading => 'Caricamento specie probabili...';

  @override
  String get previewAllowedSpeciesEmpty =>
      'Nessuna specie soddisfa i criteri del filtro';

  @override
  String get settingsSpectrogramTheme => 'Schema colori sonogrammi';

  @override
  String get settingsSpectrogramThemeHelp =>
      'Seleziona la gamma di colori per la generazione dei sonogrammi';

  @override
  String get settingsSpectrogramThemeGrayscale => 'Scala di grigio';

  @override
  String get settingsSpectrogramThemeColored => 'Colorata';

  @override
  String get settingsSpeciesListsManage => 'Gestisci liste specie';

  @override
  String get customListsTitle => 'Liste Specie Personalizzate';

  @override
  String get customListsCreate => 'Crea Lista';

  @override
  String get customListsImport => 'Importa da File';

  @override
  String get customListsEdit => 'Modifica Lista Specie';

  @override
  String get customListsDelete => 'Elimina Lista';

  @override
  String get customListsNameLabel => 'Nome della Lista';

  @override
  String get customListsNameError => 'Il nome della lista non può essere vuoto';

  @override
  String get customListsDeleteConfirm =>
      'Sei sicuro di voler eliminare questa lista?';

  @override
  String get customListsAddSpecies => 'Aggiungi/Rimuovi Specie';

  @override
  String get customListsSearchPlaceholder => 'Cerca specie per nome...';

  @override
  String get customListsNoLists =>
      'Nessuna lista specie personalizzata creata.';

  @override
  String get customListsActive => 'Filtro Attivo';

  @override
  String get customListsUseAsFilter => 'Usa come Filtro';

  @override
  String customListsImportSuccess(int count) {
    return 'Lista importata con successo con $count specie!';
  }

  @override
  String get customListsImportHint =>
      'Seleziona un file di testo (.txt) contenente una specie per riga.';

  @override
  String get customListsOnlySelected => 'Specie selezionate';

  @override
  String get customListsExport => 'Esporta Lista';

  @override
  String get customListsExportSuccess => 'Lista esportata con successo!';

  @override
  String get customListsExportError =>
      'Errore durante l\'esportazione della lista';

  @override
  String get customListsExportEmptyError =>
      'Impossibile esportare una lista vuota';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingStart => 'Inizia';

  @override
  String get onboardingTitle1 => 'Benvenuto';

  @override
  String get onboardingDesc1 =>
      'Analizza in blocco registrazioni audio per rilevare e identificare automaticamente le specie di uccelli presenti.';

  @override
  String get onboardingTitle2 => 'Analisi Audio AI';

  @override
  String get onboardingDesc2 =>
      'Grazie alla potenza di BirdNET AI, visualizza spettrogrammi dettagliati e ascolta le rilevazioni in tempo reale.';

  @override
  String get onboardingTitle3 => 'Filtri Avanzati';

  @override
  String get onboardingDesc3 =>
      'Riduci i falsi positivi usando filtri geografici GPS o crea liste di specie personalizzate su misura per le tue esigenze.';

  @override
  String get onboardingTitle4 => 'Pronto a Partire';

  @override
  String get onboardingDesc4 =>
      'Seleziona una cartella contenente le tue registrazioni audio e avvia subito la tua prima analisi acustica!';

  @override
  String get settingsThemeMode => 'Tema dell\'applicazione';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsThemeModeHelp =>
      'Scegli tra un tema chiaro pulito, la modalità scura o segui le impostazioni del tuo sistema.';

  @override
  String get settingsUpdateSectionTitle => 'Aggiornamenti Applicazione';

  @override
  String get settingsUpdateCurrentVersion => 'Versione Corrente';

  @override
  String get settingsUpdateUrlLabel =>
      'URL Server Verifica Aggiornamenti (JSON)';

  @override
  String get settingsUpdateCheckButton => 'Controlla Aggiornamenti';

  @override
  String get settingsUpdateTitle => 'Nuova Versione Disponibile!';

  @override
  String get settingsUpdateChangelogHeader => 'Note di Rilascio:';

  @override
  String get settingsUpdateLater => 'Più tardi';

  @override
  String get settingsUpdateNow => 'Aggiorna Ora';

  @override
  String get settingsUpdateLatestTitle => 'App Aggiornata!';

  @override
  String get settingsUpdateLatestDesc =>
      'Stai già utilizzando l\'ultima versione dell\'applicazione.';

  @override
  String get settingsUpdateError => 'Impossibile controllare gli aggiornamenti';

  @override
  String get settingsUpdateNoChangelog => 'Nessuna nota di rilascio fornita.';
}
