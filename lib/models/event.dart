import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  final DateTime eventDate;
  final DateTime startTime;
  final DateTime endTime;
  final String eventTitle;
  final String creator; // ID of the person who created the event
  List<String> subscribers = []; // IDs of people subscribed to this event
  String? pictureUrl;
  String? group; // ID of the group this event is associated with

  Event(
      {required this.eventDate,
      required this.eventTitle,
      required this.startTime,
      required this.endTime,
      required this.creator});

  Event.fromMap(Map<String, dynamic> data, String id)
      : eventDate = data['date'].toDate(),
        startTime = data['start_time'].toDate(),
        endTime = data['end_time'].toDate(),
        eventTitle = data['title'],
        creator = data['creator'],
        subscribers = List<String>.from(data['subscribers']);
}
