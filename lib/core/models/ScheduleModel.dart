// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:shakti/core/models/SubjectModel.dart';

class ScheduleModel {
  final String? startTimeInMillis;
  final String? endTimeInMillis;
  final SubjectModel? subject;
  final String? repeatEndDateInMillis;
  final bool? canRepeat;
  final String? repeatRule;
  ScheduleModel({
    this.startTimeInMillis,
    this.endTimeInMillis,
    this.subject,
    this.repeatEndDateInMillis,
    this.canRepeat,
    this.repeatRule,
  });

  ScheduleModel copyWith({
    String? startTimeInMillis,
    String? endTimeInMillis,
    SubjectModel? subject,
    String? repeatEndDateInMillis,
    bool? canRepeat,
    String? repeatRule,
  }) {
    return ScheduleModel(
      startTimeInMillis: startTimeInMillis ?? this.startTimeInMillis,
      endTimeInMillis: endTimeInMillis ?? this.endTimeInMillis,
      subject: subject ?? this.subject,
      repeatEndDateInMillis:
          repeatEndDateInMillis ?? this.repeatEndDateInMillis,
      canRepeat: canRepeat ?? this.canRepeat,
      repeatRule: repeatRule ?? this.repeatRule,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startTimeInMillis': startTimeInMillis,
      'endTimeInMillis': endTimeInMillis,
      'subject': subject?.toMap(),
      'repeatEndDateInMillis': repeatEndDateInMillis,
      'canRepeat': canRepeat,
      'repeatRule': repeatRule,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      startTimeInMillis:
          map['startTimeInMillis'] != null
              ? map['startTimeInMillis'] as String
              : null,
      endTimeInMillis:
          map['endTimeInMillis'] != null
              ? map['endTimeInMillis'] as String
              : null,
      subject:
          map['subject'] != null
              ? SubjectModel.fromMap(map['subject'] as Map<String, dynamic>)
              : null,
      repeatEndDateInMillis:
          map['repeatEndDateInMillis'] != null
              ? map['repeatEndDateInMillis'] as String
              : null,
      canRepeat: map['canRepeat'] != null ? map['canRepeat'] as bool : null,
      repeatRule:
          map['repeatRule'] != null ? map['repeatRule'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromJson(String source) =>
      ScheduleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ScheduleModel(startTimeInMillis: $startTimeInMillis, endTimeInMillis: $endTimeInMillis, subject: $subject, repeatEndDateInMillis: $repeatEndDateInMillis, canRepeat: $canRepeat, repeatRule: $repeatRule)';
  }

  @override
  bool operator ==(covariant ScheduleModel other) {
    if (identical(this, other)) return true;

    return other.startTimeInMillis == startTimeInMillis &&
        other.endTimeInMillis == endTimeInMillis &&
        other.subject == subject &&
        other.repeatEndDateInMillis == repeatEndDateInMillis &&
        other.canRepeat == canRepeat &&
        other.repeatRule == repeatRule;
  }

  @override
  int get hashCode {
    return startTimeInMillis.hashCode ^
        endTimeInMillis.hashCode ^
        subject.hashCode ^
        repeatEndDateInMillis.hashCode ^
        canRepeat.hashCode ^
        repeatRule.hashCode;
  }
}
