import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Model download state ─────────────────────────────────────────────────

enum ModelStatus { checking, ready, downloading, error }

class ModelState {
  final ModelStatus status;
  final String? error;

  const ModelState({
    required this.status,
    this.error,
  });

  bool get isReady => status == ModelStatus.ready;
  bool get isDownloading => status == ModelStatus.downloading;
  bool get hasError => status == ModelStatus.error;
}

// ─── Notifier ─────────────────────────────────────────────────────────────

class ModelNotifier extends AsyncNotifier<ModelState> {
  @override
  Future<ModelState> build() async {
    return const ModelState(status: ModelStatus.ready);
  }

  String get mainModelPath => 'assets/model/BirdNET_GLOBAL_6K_V2.4_Model_FP16.tflite';
  String get metaModelPath => 'assets/model/BirdNET_GLOBAL_6K_V2.4_MData_Model_V2_FP16.tflite';
  
  // The labels path is now determined dynamically based on locale in AnalysisScreen
  // String get labelsPath => ...

  Future<void> downloadModels() async {
    // No-op, models are now embedded in assets.
    state = const AsyncData(ModelState(status: ModelStatus.ready));
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────

final modelProvider =
    AsyncNotifierProvider<ModelNotifier, ModelState>(ModelNotifier.new);
