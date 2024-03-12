import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Group {
  final String groupName;
  List<String> members;
  String? id;

  Group({required this.groupName, this.members = const []});

  Group.fromMap(Map<String, dynamic> data)
      : groupName = data['name'],
        id = data['id'],
        members = List<String>.from(data['members']);

  Future<void> addMember(User user) async {
    members.add(user.uid);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupName)
        .update({
      'members': FieldValue.arrayUnion([user.uid])
    });
  }

  Future<void> removeMember(User user) async {
    members.remove(user);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupName)
        .update({
      'members': FieldValue.arrayRemove([user.uid])
    });
  }

  Future<void> createGroup() async {
    var user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('groups').doc(groupName).set({
      'name': groupName,
      'members': [user!.uid]
    });
  }

  toMap() {
    return {'name': groupName, 'members': members.map((e) => e).toList()};
  }
}
