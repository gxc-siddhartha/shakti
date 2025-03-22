import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/instance_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/typedefs.dart';

class HomeRepository {
  final GoogleSignIn googleSignIn = Get.find();
  final FirebaseAuth _auth = Get.find<FirebaseAuth>();
  final FirebaseFirestore _firestore = Get.find<FirebaseFirestore>();

  FutureEither<void> createSubject(SubjectModel subject) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Create a reference to the subjects collection for the current user
      final subjectsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects');

      // Add the subject to Firestore
      await subjectsRef
          .doc(subject.subjectName!.toLowerCase().replaceAll(" ", "_"))
          .set(subject.toMap());

      return right(null);
    } catch (e) {
      return left('Failed to create subject: ${e.toString()}');
    }
  }

  FutureEither<void> createSchedule(ScheduleModel schedule) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Create a reference to the subjects collection for the current user
      final scheduleRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('schedules');

      // Add the subject to Firestore
      await scheduleRef
          .doc(
            "${schedule.subject!.subjectName!.toLowerCase().replaceAll(" ", "_")}_${DateTime.now().millisecondsSinceEpoch}",
          )
          .set(schedule.toMap());

      return right(null);
    } catch (e) {
      return left('Failed to create subject: ${e.toString()}');
    }
  }

  FutureEither<List<SubjectModel>> getSubjects() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left('User not authenticated');
      }

      // Reference to the user's subjects collection
      final subjectsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects');

      // Get all documents in the collection with pagination to avoid large data transfers
      final querySnapshot = await subjectsRef.limit(100).get();

      // Convert each document to a SubjectModel
      final subjects =
          querySnapshot.docs
              .map((doc) => SubjectModel.fromMap(doc.data()))
              .toList();

      return right(subjects);
    } catch (e) {
      return left('Failed to fetch subjects: ${e.toString()}');
    }
  }

  FutureEither<List<ScheduleModel>> getSchedules() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left('User not authenticated');
      }

      // Reference to the user's schedules collection
      final schedulesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('schedules');

      // Get documents with a reasonable limit to avoid large data transfers
      final querySnapshot = await schedulesRef.limit(100).get();

      // Convert each document to a ScheduleModel
      final schedules =
          querySnapshot.docs
              .map((doc) => ScheduleModel.fromMap(doc.data()))
              .toList();

      return right(schedules);
    } catch (e) {
      return left('Failed to fetch schedules: ${e.toString()}');
    }
  }

  FutureEither<void> deleteSubject(String subjectName) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Subject document ID format
      String subjectDocId = subjectName.toLowerCase().replaceAll(" ", "_");

      // Reference to the subject document
      final subjectRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectDocId);

      // Get the subject data to check if it exists
      final subjectSnapshot = await subjectRef.get();
      if (!subjectSnapshot.exists) {
        return left('Subject not found');
      }

      // Try to use a transaction for better atomicity
      try {
        await _firestore.runTransaction((transaction) async {
          // 1. Delete known subcollections if they exist
          final knownSubcollections = [
            'schedules',
            'attendance',
            // Add all other possible subcollections here
          ];

          for (final subcollName in knownSubcollections) {
            final subcollDocs =
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('subjects')
                    .doc(subjectDocId)
                    .collection(subcollName)
                    .limit(100) // Limit to avoid transaction size limits
                    .get();

            for (final doc in subcollDocs.docs) {
              transaction.delete(doc.reference);
            }
          }

          // 2. Delete related schedules (with limit for transaction)
          final FieldPath subjectNamePath = FieldPath([
            'subject',
            'subjectName',
          ]);
          final relatedSchedules =
              await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('schedules')
                  .where(subjectNamePath, isEqualTo: subjectName)
                  .limit(100)
                  .get();

          for (final doc in relatedSchedules.docs) {
            transaction.delete(doc.reference);
          }

          // 3. Finally delete the subject document itself
          transaction.delete(subjectRef);
        });
      } catch (transactionError) {
        // If transaction fails (e.g., due to size limits), fallback to batch operations

        // 1. Delete subcollections in chunks with batches
        final knownSubcollections = [
          'schedules',
          'attendance',
          // Add all other possible subcollections here
        ];

        for (final subcollName in knownSubcollections) {
          await _deleteCollectionInChunks(
            _firestore
                .collection('users')
                .doc(user.uid)
                .collection('subjects')
                .doc(subjectDocId)
                .collection(subcollName),
            batchSize: 100,
          );
        }

        // 2. Delete related schedules in chunks
        await _deleteSchedulesForSubject(user.uid, subjectName, batchSize: 100);

        // 3. Finally delete the subject document itself
        await subjectRef.delete();
      }

      return right(null);
    } catch (e) {
      return left('Failed to delete subject: ${e.toString()}');
    }
  }

  // Helper method to delete a collection in chunks
  Future<void> _deleteCollectionInChunks(
    CollectionReference collectionRef, {
    int batchSize = 100,
  }) async {
    // Get the first batch of documents
    QuerySnapshot querySnapshot = await collectionRef.limit(batchSize).get();

    // Continue deleting batches until no documents are left
    while (querySnapshot.docs.isNotEmpty) {
      // Create a new batch
      WriteBatch batch = _firestore.batch();

      // Add delete operations to the batch
      for (DocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Get the next batch
      querySnapshot = await collectionRef.limit(batchSize).get();
    }
  }

  // Helper method to delete schedules related to a subject in chunks
  Future<void> _deleteSchedulesForSubject(
    String userId,
    String subjectName, {
    int batchSize = 100,
  }) async {
    final schedulesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('schedules');

    bool hasMoreSchedules = true;

    // Use a custom field path for the nested subject.subjectName field
    FieldPath subjectNamePath = FieldPath(['subject', 'subjectName']);

    // Continue until all matching documents are deleted
    while (hasMoreSchedules) {
      // Query for a batch of schedules with this subject
      QuerySnapshot querySnapshot =
          await schedulesRef
              .where(subjectNamePath, isEqualTo: subjectName)
              .limit(batchSize)
              .get();

      if (querySnapshot.docs.isEmpty) {
        hasMoreSchedules = false;
        continue;
      }

      // Create a batch
      WriteBatch batch = _firestore.batch();

      // Add delete operations to the batch
      for (DocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();
    }
  }

  // Add this to HomeRepository class
  FutureEither<void> deleteSchedule(ScheduleModel schedule) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return left("User not found");
      }

      // Reference to the schedules collection
      final schedulesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('schedules');

      // We need to find the document ID
      QuerySnapshot querySnapshot;

      // We'll use the subject name and start time as unique identifiers
      if (schedule.subject?.subjectName != null &&
          schedule.startTimeInMillis != null) {
        // Use a compound query instead of two separate filters
        final FieldPath subjectNamePath = FieldPath(['subject', 'subjectName']);

        querySnapshot =
            await schedulesRef
                .where(
                  subjectNamePath,
                  isEqualTo: schedule.subject!.subjectName,
                )
                .where(
                  'startTimeInMillis',
                  isEqualTo: schedule.startTimeInMillis,
                )
                .limit(1) // We only need one match
                .get();

        if (querySnapshot.docs.isEmpty) {
          return left("Schedule not found");
        }

        // Delete the matching document
        await schedulesRef.doc(querySnapshot.docs.first.id).delete();
        return right(null);
      } else {
        return left(
          "Cannot identify schedule: missing subject name or start time",
        );
      }
    } catch (e) {
      return left('Failed to delete schedule: ${e.toString()}');
    }
  }
}
