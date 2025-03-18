// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:shakti/core/models/SubjectModel.dart';

class ScheduleModel {
  final String? startTimeInMillis;
  final String? endTimeInMillis;
  final SubjectModel? subject;
  final bool? canRepeat;
  ScheduleModel({
    this.startTimeInMillis,
    this.endTimeInMillis,
    this.subject,
    this.canRepeat,
  });

  ScheduleModel copyWith({
    String? startTimeInMillis,
    String? endTimeInMillis,
    SubjectModel? subject,
    bool? canRepeat,
  }) {
    return ScheduleModel(
      startTimeInMillis: startTimeInMillis ?? this.startTimeInMillis,
      endTimeInMillis: endTimeInMillis ?? this.endTimeInMillis,
      subject: subject ?? this.subject,
      canRepeat: canRepeat ?? this.canRepeat,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startTimeInMillis': startTimeInMillis,
      'endTimeInMillis': endTimeInMillis,
      'subject': subject?.toMap(),
      'canRepeat': canRepeat,
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
      canRepeat: map['canRepeat'] != null ? map['canRepeat'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromJson(String source) =>
      ScheduleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ScheduleModel(startTimeInMillis: $startTimeInMillis, endTimeInMillis: $endTimeInMillis, subject: $subject, canRepeat: $canRepeat)';
  }

  @override
  bool operator ==(covariant ScheduleModel other) {
    if (identical(this, other)) return true;

    return other.startTimeInMillis == startTimeInMillis &&
        other.endTimeInMillis == endTimeInMillis &&
        other.subject == subject &&
        other.canRepeat == canRepeat;
  }

  @override
  int get hashCode {
    return startTimeInMillis.hashCode ^
        endTimeInMillis.hashCode ^
        subject.hashCode ^
        canRepeat.hashCode;
  }
}
