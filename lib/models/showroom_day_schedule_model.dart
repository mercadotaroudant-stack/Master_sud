/// Horaire d'ouverture d'un showroom pour UN jour de la semaine.
/// Aucune heure n'est codée en dur : tout vient de Firebase
/// (showroom.openingSchedule), configuré depuis le Dashboard.
///
/// Firestore (subfield of showroom doc): openingSchedule: {
///   "1": {"open": "08:00", "close": "18:30", "closed": false}, // Lundi
///   "2": {...}, ... "7": {...} // Dimanche
/// }
/// La clé correspond à DateTime.weekday (1 = lundi ... 7 = dimanche).
class ShowroomDaySchedule {
  final bool closed;
  final String? open; // format "HH:mm"
  final String? close; // format "HH:mm"

  const ShowroomDaySchedule({this.closed = false, this.open, this.close});

  /// Vrai seulement si le jour n'est pas marqué fermé ET que les deux
  /// horaires sont valides.
  bool get hasValidHours =>
      !closed && open != null && close != null && _parseMinutes(open!) != null && _parseMinutes(close!) != null;

  /// Horaire lisible "08:00 - 18:30", ou null si indisponible.
  String? get label => hasValidHours ? '$open - $close' : null;

  /// Vérifie si l'heure [now] (TimeOfDay-like en minutes depuis minuit) est
  /// comprise dans le créneau d'ouverture de ce jour.
  bool isOpenAt(DateTime now) {
    if (!hasValidHours) return false;
    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = _parseMinutes(open!)!;
    final closeMinutes = _parseMinutes(close!)!;
    if (closeMinutes <= openMinutes) {
      // Créneau traversant minuit (ex: 20:00 - 02:00)
      return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
    }
    return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
  }

  static int? _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  factory ShowroomDaySchedule.fromMap(Map<String, dynamic> map) {
    return ShowroomDaySchedule(
      closed: (map['closed'] ?? false) as bool,
      open: map['open'] as String?,
      close: map['close'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {'closed': closed, 'open': open, 'close': close};
}
