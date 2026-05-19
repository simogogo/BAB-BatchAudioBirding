enum FilterMode { none, geographic, speciesList }

class FilterSettings {
  final FilterMode mode;

  // Geographic filter
  final double? latitude;
  final double? longitude;
  final int? week; // 1–48
  final double locationThreshold; // 0.01 - 0.99

  // Species list filter
  final List<String> speciesList;
  final String? speciesListPath;
  final int? speciesListId;
  final String? speciesListName;

  const FilterSettings({
    this.mode = FilterMode.none,
    this.latitude,
    this.longitude,
    this.week,
    this.locationThreshold = 0.03,
    this.speciesList = const [],
    this.speciesListPath,
    this.speciesListId,
    this.speciesListName,
  });

  bool get isGeoValid =>
      latitude != null && longitude != null && week != null;

  FilterSettings copyWith({
    FilterMode? mode,
    double? latitude,
    double? longitude,
    int? week,
    double? locationThreshold,
    List<String>? speciesList,
    String? speciesListPath,
    int? speciesListId,
    String? speciesListName,
  }) {
    return FilterSettings(
      mode: mode ?? this.mode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      week: week ?? this.week,
      locationThreshold: locationThreshold ?? this.locationThreshold,
      speciesList: speciesList ?? this.speciesList,
      speciesListPath: speciesListPath ?? this.speciesListPath,
      speciesListId: speciesListId ?? this.speciesListId,
      speciesListName: speciesListName ?? this.speciesListName,
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'latitude': latitude,
    'longitude': longitude,
    'week': week,
    'locationThreshold': locationThreshold,
    'speciesList': speciesList,
    'speciesListPath': speciesListPath,
    'speciesListId': speciesListId,
    'speciesListName': speciesListName,
  };

  factory FilterSettings.fromJson(Map<String, dynamic> json) {
    return FilterSettings(
      mode: FilterMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => FilterMode.none,
      ),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      week: json['week'] as int?,
      locationThreshold: (json['locationThreshold'] as num?)?.toDouble() ?? 0.03,
      speciesList: List<String>.from(json['speciesList'] ?? []),
      speciesListPath: json['speciesListPath'] as String?,
      speciesListId: json['speciesListId'] as int?,
      speciesListName: json['speciesListName'] as String?,
    );
  }
}
