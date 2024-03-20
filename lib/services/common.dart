// Responsible for finding users with similar availabilities and returning their username, email and picture

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduleup/models/user.dart';

Future<List<SuperUser>> findMatchingTimes(
    DateTime? startTime, DateTime? endTime) {
  // availabilities is a subcollection containing availability documents with id's
  return FirebaseFirestore.instance
      .collection('availabilities')
      .where('startTime', isGreaterThanOrEqualTo: startTime)
      .where('endTime', isLessThanOrEqualTo: endTime)
      .get()
      .then((snapshot) async {
    var users = <SuperUser>[];
    for (var doc in snapshot.docs) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc.id)
          .get();
      var user = SuperUser.fromJson(userDoc.data()!);
      users.add(user);
    }
    return users;
  });
}
