// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';

class AttendanceModel {
  final SubjectModel? subject;
  final ScheduleModel? schedule;
  final String? status;
  final String? dateInMillis;
  AttendanceModel({
    this.subject,
    this.schedule,
    this.status,
    this.dateInMillis,
  });

  AttendanceModel copyWith({
    SubjectModel? subject,
    ScheduleModel? schedule,
    String? status,
    String? dateInMillis,
  }) {
    return AttendanceModel(
      subject: subject ?? this.subject,
      schedule: schedule ?? this.schedule,
      status: status ?? this.status,
      dateInMillis: dateInMillis ?? this.dateInMillis,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subject': subject?.toMap(),
      'schedule': schedule?.toMap(),
      'status': status,
      'dateInMillis': dateInMillis,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      subject:
          map['subject'] != null
              ? SubjectModel.fromMap(map['subject'] as Map<String, dynamic>)
              : null,
      schedule:
          map['schedule'] != null
              ? ScheduleModel.fromMap(map['schedule'] as Map<String, dynamic>)
              : null,
      status: map['status'] != null ? map['status'] as String : null,
      dateInMillis:
          map['dateInMillis'] != null ? map['dateInMillis'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AttendanceModel(subject: $subject, schedule: $schedule, status: $status, dateInMillis: $dateInMillis)';
  }

  @override
  bool operator ==(covariant AttendanceModel other) {
    if (identical(this, other)) return true;

    return other.subject == subject &&
        other.schedule == schedule &&
        other.status == status &&
        other.dateInMillis == dateInMillis;
  }

  @override
  int get hashCode {
    return subject.hashCode ^
        schedule.hashCode ^
        status.hashCode ^
        dateInMillis.hashCode;
  }
}
