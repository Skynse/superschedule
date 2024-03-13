import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superschedule/models/user.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Stream<List<SuperUser>> getFriends() async* {
    var friends = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      if (value.data()!.containsKey('friends')) {
        return List<Map<String, dynamic>>.from(value['friends']);
      } else {
        return <Map<String, dynamic>>[];
      }
    });

    yield friends
        .map((friend) => SuperUser.fromJson(friend as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _auth.currentUser!.updateDisplayName(displayName);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'email': email,
      'display_name': displayName,
    });
  }

  Future<void> sendAlert(String message, String userId, String title) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('alerts')
        .add({
      'title': title,
      'description': message,
      'read': false,
    });
  }

  void createEvent(String text, DateTime dateTime, DateTime start, DateTime end,
      String? group) {
    FirebaseFirestore.instance.collection('events').add({
      'title': text,
      'date': dateTime,
      'start_time': start,
      'end_time': end,
      // document reference to creator
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'group': group ?? '',

      // array of document references to subscribers
      'subscribers': [],
    });
  }
}

final firebaseServiceProvider =
    ChangeNotifierProvider.autoDispose<FirebaseService>((ref) {
  return FirebaseService();
});
