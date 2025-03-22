// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SubjectModel {
  final String? subjectName;
  final int? totalEvents;
  final int? attendedEvents;
  final int? occuredEvents;
  final int? missedEvents;
  final int? currentPercentage;
  final int? percentageRequiredToCover;
  SubjectModel({
    this.subjectName,
    this.totalEvents,
    this.attendedEvents,
    this.occuredEvents,
    this.missedEvents,
    this.currentPercentage,
    this.percentageRequiredToCover,
  });

  SubjectModel copyWith({
    String? subjectName,
    int? totalEvents,
    int? attendedEvents,
    int? occuredEvents,
    int? missedEvents,
    int? currentPercentage,
    int? percentageRequiredToCover,
  }) {
    return SubjectModel(
      subjectName: subjectName ?? this.subjectName,
      totalEvents: totalEvents ?? this.totalEvents,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      occuredEvents: occuredEvents ?? this.occuredEvents,
      missedEvents: missedEvents ?? this.missedEvents,
      currentPercentage: currentPercentage ?? this.currentPercentage,
      percentageRequiredToCover:
          percentageRequiredToCover ?? this.percentageRequiredToCover,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subjectName': subjectName,
      'totalEvents': totalEvents,
      'attendedEvents': attendedEvents,
      'occuredEvents': occuredEvents,
      'missedEvents': missedEvents,
      'currentPercentage': currentPercentage,
      'percentageRequiredToCover': percentageRequiredToCover,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      subjectName:
          map['subjectName'] != null ? map['subjectName'] as String : null,
      totalEvents:
          map['totalEvents'] != null ? map['totalEvents'] as int : null,
      attendedEvents:
          map['attendedEvents'] != null ? map['attendedEvents'] as int : null,
      occuredEvents:
          map['occuredEvents'] != null ? map['occuredEvents'] as int : null,
      missedEvents:
          map['missedEvents'] != null ? map['missedEvents'] as int : null,
      currentPercentage:
          map['currentPercentage'] != null
              ? map['currentPercentage'] as int
              : null,
      percentageRequiredToCover:
          map['percentageRequiredToCover'] != null
              ? map['percentageRequiredToCover'] as int
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubjectModel.fromJson(String source) =>
      SubjectModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SubjectModel(subjectName: $subjectName, totalEvents: $totalEvents, attendedEvents: $attendedEvents, occuredEvents: $occuredEvents, missedEvents: $missedEvents, currentPercentage: $currentPercentage, percentageRequiredToCover: $percentageRequiredToCover)';
  }

  @override
  bool operator ==(covariant SubjectModel other) {
    if (identical(this, other)) return true;

    return other.subjectName == subjectName &&
        other.totalEvents == totalEvents &&
        other.attendedEvents == attendedEvents &&
        other.occuredEvents == occuredEvents &&
        other.missedEvents == missedEvents &&
        other.currentPercentage == currentPercentage &&
        other.percentageRequiredToCover == percentageRequiredToCover;
  }

  @override
  int get hashCode {
    return subjectName.hashCode ^
        totalEvents.hashCode ^
        attendedEvents.hashCode ^
        occuredEvents.hashCode ^
        missedEvents.hashCode ^
        currentPercentage.hashCode ^
        percentageRequiredToCover.hashCode;
  }
}
