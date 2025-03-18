// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SubjectModel {
  final String? subjectName;
  final String? totalEvents;
  final String? attendedEvents;
  final String? occuredEvents;
  final String? missedEvents;
  final String? currentPercentage;
  final String? percentageRequiredToCover;
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
    String? totalEvents,
    String? attendedEvents,
    String? occuredEvents,
    String? missedEvents,
    String? currentPercentage,
    String? percentageRequiredToCover,
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
          map['totalEvents'] != null ? map['totalEvents'] as String : null,
      attendedEvents:
          map['attendedEvents'] != null
              ? map['attendedEvents'] as String
              : null,
      occuredEvents:
          map['occuredEvents'] != null ? map['occuredEvents'] as String : null,
      missedEvents:
          map['missedEvents'] != null ? map['missedEvents'] as String : null,
      currentPercentage:
          map['currentPercentage'] != null
              ? map['currentPercentage'] as String
              : null,
      percentageRequiredToCover:
          map['percentageRequiredToCover'] != null
              ? map['percentageRequiredToCover'] as String
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
