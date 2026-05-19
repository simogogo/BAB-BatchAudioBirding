import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// ─── Model download info ────────────────────────────────────────────────────

class _ModelInfo {
  final String name;
  final String url;
  const _ModelInfo({required this.name, required this.url});
}

const _mainModel = _ModelInfo(
  name: 'BirdNET_GLOBAL_6K_V2.4_Model_FP32.tflite',
  url:
      'https://github.com/woheller69/whoBIRD-TFlite/releases/download/V1.0/BirdNET_GLOBAL_6K_V2.4_Model_FP32.tflite',
);

const _metaModel = _ModelInfo(
  name: 'BirdNET_GLOBAL_6K_V2.4_MData_Model_FP16.tflite',
  url:
      'https://github.com/woheller69/whoBIRD-TFlite/releases/download/V1.0/BirdNET_GLOBAL_6K_V2.4_MData_Model_FP16.tflite',
);

const _labelsFile = _ModelInfo(
  name: 'BirdNET_GLOBAL_6K_V2.4_Labels.txt',
  url:
      'https://github.com/woheller69/whoBIRD-TFlite/releases/download/V1.0/BirdNET_GLOBAL_6K_V2.4_Labels_af.txt',
);

// ─── Progress event ──────────────────────────────────────────────────────────

class DownloadProgress {
  final String fileName;
  final int received;
  final int total;
  final bool done;

  const DownloadProgress({
    required this.fileName,
    required this.received,
    required this.total,
    required this.done,
  });

  double get fraction => (total > 0) ? received / total : 0.0;
  int get percent => (fraction * 100).clamp(0, 100).round();

  String get sizeLabel {
    if (total <= 0) return '';
    final mb = received / 1024 / 1024;
    final totalMb = total / 1024 / 1024;
    return '${mb.toStringAsFixed(1)} / ${totalMb.toStringAsFixed(1)} MB';
  }
}

// ─── ModelManager ────────────────────────────────────────────────────────────

class ModelManager {
  static final ModelManager _instance = ModelManager._();
  factory ModelManager() => _instance;
  ModelManager._();

  late Directory _modelsDir;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final appDir = await getApplicationDocumentsDirectory();
    _modelsDir = Directory('${appDir.path}/models');
    await _modelsDir.create(recursive: true);
    _initialized = true;
  }

  String get mainModelPath => '${_modelsDir.path}/${_mainModel.name}';
  String get metaModelPath => '${_modelsDir.path}/${_metaModel.name}';
  String get labelsPath => '${_modelsDir.path}/${_labelsFile.name}';

  bool get mainModelExists => File(mainModelPath).existsSync();
  bool get metaModelExists => File(metaModelPath).existsSync();
  bool get labelsExists => File(labelsPath).existsSync();
  bool get allReady => mainModelExists && metaModelExists && labelsExists;

  /// Streams [DownloadProgress] events while downloading all required files.
  Stream<DownloadProgress> downloadAll() async* {
    await init();
    for (final info in [_mainModel, _metaModel, _labelsFile]) {
      final dest = '${_modelsDir.path}/${info.name}';
      if (File(dest).existsSync()) {
        // Already present — emit a "done" event and continue
        yield DownloadProgress(
          fileName: info.name,
          received: 1,
          total: 1,
          done: true,
        );
        continue;
      }
      yield* _downloadOne(info, dest);
    }
  }

  Stream<DownloadProgress> _downloadOne(
    _ModelInfo info,
    String destPath,
  ) {
    final ctrl = StreamController<DownloadProgress>();
    final dio = Dio(BaseOptions(receiveTimeout: const Duration(minutes: 10)));

    dio
        .download(
          info.url,
          destPath,
          onReceiveProgress: (received, total) {
            ctrl.add(DownloadProgress(
              fileName: info.name,
              received: received,
              total: total,
              done: false,
            ));
          },
        )
        .then((_) {
          ctrl.add(DownloadProgress(
            fileName: info.name,
            received: 1,
            total: 1,
            done: true,
          ));
        })
        .catchError((Object e) {
          // Delete partial file on error
          final f = File(destPath);
          if (f.existsSync()) f.deleteSync();
          ctrl.addError(e);
        })
        .whenComplete(ctrl.close);

    return ctrl.stream;
  }
}
