class CustomSpeciesList {
  final int id;
  final String name;
  final int speciesCount;

  const CustomSpeciesList({
    required this.id,
    required this.name,
    required this.speciesCount,
  });

  CustomSpeciesList copyWith({
    int? id,
    String? name,
    int? speciesCount,
  }) {
    return CustomSpeciesList(
      id: id ?? this.id,
      name: name ?? this.name,
      speciesCount: speciesCount ?? this.speciesCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'speciesCount': speciesCount,
      };

  factory CustomSpeciesList.fromJson(Map<String, dynamic> json) {
    return CustomSpeciesList(
      id: json['id'] as int,
      name: json['name'] as String,
      speciesCount: (json['species_count'] ?? json['speciesCount'] ?? 0) as int,
    );
  }
}
