// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Batch Audio Birding';

  @override
  String get splashDownloadingModel => 'Descargando modelo de IA...';

  @override
  String get splashModelReady => 'Modelo listo';

  @override
  String get splashDownloadError => 'Error de descarga. Comprueba tu conexión.';

  @override
  String get splashRetry => 'Reintentar';

  @override
  String splashDownloadProgress(String percent, String speed) {
    return '$percent% — $speed';
  }

  @override
  String get homeTitle => 'Batch Audio Birding';

  @override
  String get homeSelectFolder => 'Seleccionar Carpeta';

  @override
  String get homeSelectFolderSubtitle =>
      'Elige una carpeta con grabaciones de audio';

  @override
  String homeLastFolder(String path) {
    return 'Última carpeta: $path';
  }

  @override
  String get homeNoLastFolder => 'Ninguna carpeta seleccionada';

  @override
  String homeFilesSelected(int count) {
    return '$count archivos seleccionados';
  }

  @override
  String get homeStartAnalysis => 'Iniciar Análisis';

  @override
  String get homeSettings => 'Configuración';

  @override
  String get homeFilterMode => 'Modo de filtro';

  @override
  String get homeThreshold => 'Umbral de confianza';

  @override
  String get analysisTitle => 'Análisis';

  @override
  String analysisProgress(int done, int total) {
    return '$done / $total archivos';
  }

  @override
  String analysisDetections(int count) {
    return '$count detecciones';
  }

  @override
  String get analysisStop => 'Detener';

  @override
  String get analysisExportCsv => 'Exportar CSV';

  @override
  String get analysisStatusWaiting => 'Esperando...';

  @override
  String get analysisStatusProcessing => 'Analizando...';

  @override
  String analysisStatusDone(int count) {
    return 'Completado — $count detecciones';
  }

  @override
  String analysisStatusError(String message) {
    return 'Error: $message';
  }

  @override
  String get analysisComplete => 'Análisis completado';

  @override
  String analysisTotalAudio(int hours, int min) {
    return '${hours}h ${min}m de audio';
  }

  @override
  String analysisSpeciesFound(int count) {
    return '$count especies detectadas';
  }

  @override
  String get resultsTitle => 'Resultados';

  @override
  String get resultsNoDetections => 'No se encontraron detecciones';

  @override
  String get resultsFilterThreshold => 'Confianza mínima';

  @override
  String get resultsExportFile => 'Exportar este archivo';

  @override
  String resultsTimeRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsThreshold => 'Umbral de confianza';

  @override
  String get settingsThresholdHelp =>
      'Confianza mínima para mostrar una detección (0.1 = 10%)';

  @override
  String get settingsOverlap => 'Superposición de segmentos (segundos)';

  @override
  String get settingsOverlapHelp =>
      'Superposición entre ventanas de audio de 3 segundos (0–2.9s)';

  @override
  String get settingsFilterMode => 'Filtro de especies';

  @override
  String get settingsFilterNone => 'Sin filtro';

  @override
  String get settingsFilterGeo => 'Filtro geográfico (GPS + semana)';

  @override
  String get settingsFilterList => 'Lista de especies personalizada';

  @override
  String get settingsGeoLatitude => 'Latitud';

  @override
  String get settingsGeoLongitude => 'Longitud';

  @override
  String get settingsGeoWeek => 'Semana del año (1–48)';

  @override
  String get settingsGeoUseGps => 'Usar GPS del dispositivo';

  @override
  String get settingsSpeciesListPick =>
      'Seleccionar archivo de lista de especies';

  @override
  String get settingsSpeciesListNone => 'Ningún archivo seleccionado';

  @override
  String settingsSpeciesListSelected(int count) {
    return '$count especies cargadas';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSave => 'Guardar';

  @override
  String get errorPermissionStorage =>
      'Permiso de almacenamiento requerido para leer archivos de audio';

  @override
  String get errorPermissionLocation =>
      'Permiso de ubicación requerido para el filtro geográfico';

  @override
  String get errorUnsupportedFormat => 'Formato de audio no compatible';

  @override
  String get errorNoFiles =>
      'No se encontraron archivos de audio en la carpeta seleccionada';

  @override
  String get errorModelNotFound =>
      'Modelo de IA no encontrado. Reinicia la aplicación.';

  @override
  String get csvExportSuccess => 'CSV exportado con éxito';

  @override
  String get csvExportError => 'Error al exportar CSV';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get preparingFiles => 'Preparando archivos...';

  @override
  String preparingFilesProgress(int current, int total) {
    return 'Procesando archivo $current de $total';
  }

  @override
  String get homeViewSelectedFiles => 'Ver archivos seleccionados';

  @override
  String get selectedFilesTitle => 'Archivos Seleccionados';

  @override
  String get selectedFilesRemove => 'Eliminar';

  @override
  String get detailModalTitle => 'Detalle de Detección';

  @override
  String get detailExportAudio => 'Exportar Audio';

  @override
  String get detailExportSpectrogram => 'Exportar Espectrograma';

  @override
  String get detailLoopAudio => 'Bucle';

  @override
  String get detailSpectrogramLoading => 'Generando espectrograma...';

  @override
  String get detailSpectrogramFullscreen => 'Tocar para ampliar';

  @override
  String get audioExportSuccess => 'Audio exportado con éxito al dispositivo';

  @override
  String get audioExportError => 'Error al exportar audio';

  @override
  String get spectrogramExportSuccess =>
      'Espectrograma exportado con éxito al dispositivo';

  @override
  String get spectrogramExportError => 'Error al exportar espectrograma';

  @override
  String get settingsSensitivity => 'Sensibilidad del modelo de IA';

  @override
  String get settingsSensitivityHelp =>
      'Ajusta la sensibilidad del modelo (0.5 = conservador, 1.5 = muy sensible, por defecto 1.0)';

  @override
  String get settingsLocationThreshold => 'Umbral del filtro geográfico';

  @override
  String get settingsLocationThresholdHelp =>
      'Umbral mínimo de probabilidad geográfica para incluir una especie (por defecto 0.03 = 3%)';

  @override
  String get settingsGeoPreviewAllowedSpecies =>
      'Vista previa de especies probables';

  @override
  String get previewAllowedSpeciesTitle => 'Especies Probables';

  @override
  String get previewAllowedSpeciesSearch => 'Buscar especies...';

  @override
  String get previewAllowedSpeciesLoading => 'Cargando especies probables...';

  @override
  String get previewAllowedSpeciesEmpty =>
      'Ninguna especie cumple con los criterios del filtro';

  @override
  String get settingsSpectrogramTheme => 'Esquema de colores del espectrograma';

  @override
  String get settingsSpectrogramThemeHelp =>
      'Seleccione la paleta de colores para los espectrogramas generados';

  @override
  String get settingsSpectrogramThemeGrayscale => 'Escala de grises';

  @override
  String get settingsSpectrogramThemeColored => 'Color';

  @override
  String get settingsSpeciesListsManage => 'Gestionar listas de especies';

  @override
  String get customListsTitle => 'Listas de Especies Personalizadas';

  @override
  String get customListsCreate => 'Crear Lista';

  @override
  String get customListsImport => 'Importar desde Archivo';

  @override
  String get customListsEdit => 'Editar Lista de Especies';

  @override
  String get customListsDelete => 'Eliminar Lista';

  @override
  String get customListsNameLabel => 'Nombre de la Lista';

  @override
  String get customListsNameError =>
      'El nombre de la lista no puede estar vacío';

  @override
  String get customListsDeleteConfirm =>
      '¿Está seguro de que desea eliminar esta lista?';

  @override
  String get customListsAddSpecies => 'Añadir/Eliminar Especies';

  @override
  String get customListsSearchPlaceholder => 'Buscar especies por nombre...';

  @override
  String get customListsNoLists =>
      'Aún no se han creado listas de especies personalizadas.';

  @override
  String get customListsActive => 'Filtro Activo';

  @override
  String get customListsUseAsFilter => 'Usar como Filtro';

  @override
  String customListsImportSuccess(int count) {
    return '¡Importado con éxito con $count especies!';
  }

  @override
  String get customListsImportHint =>
      'Seleccione un archivo de texto (.txt) que contenga una especie por línea.';

  @override
  String get customListsOnlySelected => 'Especies seleccionadas';

  @override
  String get customListsExport => 'Exportar Lista';

  @override
  String get customListsExportSuccess => '¡Lista exportada con éxito!';

  @override
  String get customListsExportError => 'Error al exportar la lista de especies';

  @override
  String get customListsExportEmptyError =>
      'No se puede exportar una lista de especies vacía';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get onboardingTitle1 => 'Bienvenido';

  @override
  String get onboardingDesc1 =>
      'Analice grabaciones de audio por lotes para detectar e identificar automáticamente las especies de aves presentes.';

  @override
  String get onboardingTitle2 => 'Análisis de Audio IA';

  @override
  String get onboardingDesc2 =>
      'Con la tecnología de BirdNET AI, visualice espectrogramas detallados y escuche detecciones sincronizadas dinámicamente con el audio.';

  @override
  String get onboardingTitle3 => 'Filtrado Inteligente';

  @override
  String get onboardingDesc3 =>
      'Reduzca los falsos positivos utilizando filtros geográficos GPS o cree listas de especies personalizadas adaptadas a sus necesidades.';

  @override
  String get onboardingTitle4 => 'Listo para Explorar';

  @override
  String get onboardingDesc4 =>
      '¡Seleccione una carpeta que contenga sus grabaciones de audio y comience su primer análisis acústico por lotes ahora!';

  @override
  String get settingsThemeMode => 'Tema de la aplicación';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeModeHelp =>
      'Elija entre un tema claro limpio, modo oscuro o siga la configuración de su sistema.';

  @override
  String get settingsUpdateSectionTitle => 'Actualizaciones de la aplicación';

  @override
  String get settingsUpdateCurrentVersion => 'Versión actual';

  @override
  String get settingsUpdateUrlLabel =>
      'URL del servidor de verificación (JSON)';

  @override
  String get settingsUpdateCheckButton => 'Buscar actualizaciones';

  @override
  String get settingsUpdateTitle => '¡Nueva versión disponible!';

  @override
  String get settingsUpdateChangelogHeader => 'Notas de versión:';

  @override
  String get settingsUpdateLater => 'Más tarde';

  @override
  String get settingsUpdateNow => 'Actualizar ahora';

  @override
  String get settingsUpdateLatestTitle => '¡Aplicación al día!';

  @override
  String get settingsUpdateLatestDesc =>
      'Ya está utilizando la última versión de la aplicación.';

  @override
  String get settingsUpdateError => 'Error al buscar actualizaciones';

  @override
  String get settingsUpdateNoChangelog =>
      'No se proporcionaron notas de versión.';
}
