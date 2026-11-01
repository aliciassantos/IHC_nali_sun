// Dados da planta

class PlantModel {
  final int id;
  final DateTime createdAt;
  final String userId;
  final String name;
  final String species;
  final String? imagePath;
  final int wateringFrequencyDays;
  final DateTime? lastWateredAt;
  final String luminosity;

  PlantModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.name,
    required this.species,
    this.imagePath,
    required this.wateringFrequencyDays,
    this.lastWateredAt,
    required this.luminosity,
  });

  /// Converte o objeto para um mapa compatível com o Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'user_id': userId,
      'name': name,
      'species': species,
      'image_path': imagePath,
      'watering_frequency_days': wateringFrequencyDays,
      'last_watered_at': lastWateredAt?.toUtc().toIso8601String(),
      'luminosity': luminosity,
    };
  }

  /// Cria um objeto PlantModel a partir dos dados do Supabase.
  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      id: (map['id'] as num).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      imagePath: map['image_path'] as String?,
      wateringFrequencyDays:
          (map['watering_frequency_days'] as num).toInt(),
      lastWateredAt: map['last_watered_at'] != null
          ? DateTime.parse(map['last_watered_at'] as String)
          : null,
      luminosity: map['luminosity'] as String,
    );
  }
}