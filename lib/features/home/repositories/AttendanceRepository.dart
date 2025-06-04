import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/instance_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shakti/core/models/AttendanceModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/typedefs.dart';

class AttendanceRepository {
  final GoogleSignIn googleSignIn = Get.find();
  final FirebaseAuth _auth = Get.find<FirebaseAuth>();
  final FirebaseFirestore _firestore = Get.find<FirebaseFirestore>();

  FutureEither<void> markAttendance(AttendanceModel attendance) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Create a reference to the attendance collection for the current user
      final attendanceRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(
            attendance.subject!.subjectName!.toLowerCase().replaceAll(" ", "_"),
          )
          .collection("attendance");

      // Create a unique document ID using subject name and current timestamp
      String docId =
          "${attendance.subject!.subjectName!.toLowerCase().replaceAll(" ", "_")}_${attendance.schedule!.startTimeInMillis.toString()}";

      // Check if document already exists
      final docSnapshot = await attendanceRef.doc(docId).get();

      if (docSnapshot.exists) {
        return left("Attendance already marked for this schedule");
      }

      // Add the attendance record to Firestore
      await attendanceRef.doc(docId).set(attendance.toMap());
      print("Attendance Added");

      return right(null);
    } catch (e) {
      return left('Failed to mark attendance: ${e.toString()}');
    }
  }

  FutureEither<List<AttendanceModel>> getAttendanceRecords(
    SubjectModel subject,
  ) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Get the subject document ID
      String subjectDocId = subject.subjectName!.toLowerCase().replaceAll(
        " ",
        "_",
      );

      // Reference to the user's collections
      final userRef = _firestore.collection('users').doc(user.uid);
      final userSubjectsRef = userRef.collection('subjects');
      final attendanceRef = userSubjectsRef
          .doc(subjectDocId)
          .collection("attendance");

      // Fetch all attendance records for this subject
      final snapshot = await attendanceRef.get();

      // Parse the attendance data
      List<AttendanceModel> attendanceRecords = [];
      for (var doc in snapshot.docs) {
        attendanceRecords.add(AttendanceModel.fromMap(doc.data()));
      }

      // Calculate attendance statistics
      int totalClasses = attendanceRecords.length;
      int attendedClasses =
          attendanceRecords
              .where((record) => record.status == 'Present')
              .length;
      int missedClasses = totalClasses - attendedClasses;

      // Calculate attendance percentage
      int attendancePercentage =
          totalClasses > 0
              ? ((attendedClasses / totalClasses) * 100).round()
              : 0;

      // Calculate classes needed to reach 75% attendance
      int classesNeeded = _calculateClassesNeededFor75Percent(
        attendedClasses,
        totalClasses,
      );

      // Update the subject document with the calculated values
      await userSubjectsRef.doc(subjectDocId).update({
        'attendedEvents': attendedClasses,
        'occuredEvents': totalClasses,
        'missedEvents': missedClasses,
        'currentPercentage': attendancePercentage,
        'percentageRequiredToCover': classesNeeded,
      });

      return right(attendanceRecords);
    } catch (e) {
      return left('Failed to fetch attendance records: ${e.toString()}');
    }
  }

  int _calculateClassesNeededFor75Percent(
    int attendedClasses,
    int totalClasses,
  ) {
    if (totalClasses == 0) return 0;

    // Current percentage
    double currentPercentage = (attendedClasses / totalClasses) * 100;

    // If already at or above 75%, return 0
    if (currentPercentage >= 75) return 0;

    // Formula: (attended + x) / (total + x) = 0.75
    // Solving for x: x = (0.75*total - attended) / 0.25
    double classesNeeded = (0.75 * totalClasses - attendedClasses) / 0.25;

    // Return the ceiling (round up) to ensure we reach at least 75%
    return classesNeeded.ceil();
  }

  // Add this method to AttendanceRepository class
  FutureEither<void> deleteAttendanceRecord(AttendanceModel attendance) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Get the subject document ID
      String subjectDocId = attendance.subject!.subjectName!
          .toLowerCase()
          .replaceAll(" ", "_");

      // Create the attendance document ID using the same pattern as in markAttendance
      String attendanceDocId =
          "${subjectDocId}_${attendance.schedule!.startTimeInMillis.toString()}";

      // Reference to the specific attendance document
      final attendanceDocRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectDocId)
          .collection("attendance")
          .doc(attendanceDocId);

      // Delete the attendance record
      await attendanceDocRef.delete();

      // After deletion, we need to recalculate the subject's attendance statistics
      final subjectRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectDocId);

      final attendanceRef = subjectRef.collection("attendance");
      final snapshot = await attendanceRef.get();

      // Calculate updated attendance statistics
      List<AttendanceModel> attendanceRecords = [];
      for (var doc in snapshot.docs) {
        attendanceRecords.add(AttendanceModel.fromMap(doc.data()));
      }

      int totalClasses = attendanceRecords.length;
      int attendedClasses =
          attendanceRecords
              .where((record) => record.status == 'Present')
              .length;
      int missedClasses = totalClasses - attendedClasses;

      // Calculate attendance percentage
      int attendancePercentage =
          totalClasses > 0
              ? ((attendedClasses / totalClasses) * 100).round()
              : 0;

      // Calculate classes needed to reach 75% attendance
      int classesNeeded = _calculateClassesNeededFor75Percent(
        attendedClasses,
        totalClasses,
      );

      // Update the subject document with the recalculated values
      await subjectRef.update({
        'attendedEvents': attendedClasses,
        'occuredEvents': totalClasses,
        'missedEvents': missedClasses,
        'currentPercentage': attendancePercentage,
        'percentageRequiredToCover': classesNeeded,
      });

      print("Attendance record deleted and statistics updated");
      return right(null);
    } catch (e) {
      return left('Failed to delete attendance record: ${e.toString()}');
    }
  }
}
