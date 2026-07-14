/// Service unique proposé par un showroom (ex: Teinte Machine, Livraison).
/// Chaque showroom peut avoir une liste différente de services — tout vient
/// de Firebase (showroom.services), rien n'est codé en dur. Les exemples de
/// la maquette (Teinte Machine, Livraison, Stock Disponible) ne sont que des
/// exemples visuels, jamais des valeurs par défaut.
///
/// Firestore (subfield of showroom doc): services: [
///   {id, name, iconUrl, emoji, isActive, displayOrder}
/// ]
class ShowroomService {
  final String id;
  final String name;
  final String? iconUrl;
  final String? emoji;
  final bool isActive;
  final int displayOrder;

  const ShowroomService({
    required this.id,
    required this.name,
    this.iconUrl,
    this.emoji,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory ShowroomService.fromMap(Map<String, dynamic> map) {
    return ShowroomService(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      iconUrl: (map['iconUrl'] as String?)?.trim().isNotEmpty == true ? map['iconUrl'] as String : null,
      emoji: (map['emoji'] as String?)?.trim().isNotEmpty == true ? map['emoji'] as String : null,
      isActive: (map['isActive'] ?? true) as bool,
      displayOrder: (map['displayOrder'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconUrl': iconUrl,
        'emoji': emoji,
        'isActive': isActive,
        'displayOrder': displayOrder,
      };
}
