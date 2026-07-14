import 'showroom_day_schedule_model.dart';

const List<String> _kFrenchWeekdayNames = [
  '', // index 0 unused (weekday starts at 1)
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

/// Un groupe de jours consécutifs partageant le même horaire (ou tous
/// fermés), construit uniquement à partir de [ShowroomModel.openingSchedule]
/// (Firebase). Permet d'afficher "Lundi - Samedi : 08:00 - 18:30" au lieu de
/// répéter chaque jour, sans jamais coder les jours/heures en dur.
class ShowroomScheduleGroup {
  final String daysLabel; // "Lundi - Samedi" ou "Dimanche"
  final bool isClosed;
  final String? hoursLabel; // "08:00 - 18:30", null si fermé ou invalide

  const ShowroomScheduleGroup({required this.daysLabel, required this.isClosed, this.hoursLabel});

  /// Regroupe les jours 1 (lundi) à 7 (dimanche) présents dans [schedule] en
  /// plages consécutives de même statut. Les jours absents du planning
  /// Firebase sont simplement ignorés (pas de valeur inventée).
  static List<ShowroomScheduleGroup> build(Map<int, ShowroomDaySchedule> schedule) {
    final groups = <ShowroomScheduleGroup>[];

    int? rangeStart;
    int? rangeEnd;
    String? currentSignature;
    bool? currentClosed;
    String? currentHours;

    void flush() {
      if (rangeStart == null || rangeEnd == null) return;
      final daysLabel = rangeStart == rangeEnd
          ? _kFrenchWeekdayNames[rangeStart!]
          : '${_kFrenchWeekdayNames[rangeStart!]} - ${_kFrenchWeekdayNames[rangeEnd!]}';
      groups.add(ShowroomScheduleGroup(daysLabel: daysLabel, isClosed: currentClosed ?? true, hoursLabel: currentHours));
      rangeStart = null;
      rangeEnd = null;
      currentSignature = null;
    }

    for (var day = 1; day <= 7; day++) {
      final entry = schedule[day];
      if (entry == null) {
        flush();
        continue;
      }

      final closed = entry.closed || !entry.hasValidHours;
      final signature = closed ? 'closed' : '${entry.open}-${entry.close}';

      if (currentSignature == signature && rangeEnd == day - 1) {
        rangeEnd = day;
      } else {
        flush();
        rangeStart = day;
        rangeEnd = day;
        currentSignature = signature;
        currentClosed = closed;
        currentHours = closed ? null : entry.label;
      }
    }
    flush();

    return groups;
  }
}
