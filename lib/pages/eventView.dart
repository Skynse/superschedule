import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduleup/models/event.dart';
import 'package:scheduleup/models/user.dart';
import 'package:scheduleup/services/firebase_service.dart';

class EventView extends StatefulWidget {
  Event event;
  String eventId;
  EventView({Key? key, required this.event, required this.eventId})
      : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  Future<void> _subscribeToEvent() async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .update({
      'subscribers':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  Future<void> _unsubscribeFromEvent() async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .update({
      'subscribers':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });

    if (!mounted) return;
  }

  Stream<List<SuperUser>> _getSubscribers() async* {
    var event = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();

    var subscribers = event['subscribers'];
    print(subscribers);

    List<SuperUser> subscriberData = [];

    for (var subscriber in subscribers) {
      var user = await FirebaseFirestore.instance
          .collection('users')
          .doc(subscriber)
          .get();

      subscriberData
          .add(SuperUser.fromJson(user.data() as Map<String, dynamic>));
    }

    yield subscriberData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.event.eventTitle),
          actions: [
            FirebaseAuth.instance.currentUser!.uid == widget.event.creator
                ? IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Event'),
                              content: Text(
                                  'Are you sure you want to delete this event?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('events')
                                        .doc(widget.eventId)
                                        .delete();

                                    if (mounted) {
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                    }
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          });
                    },
                    icon: Icon(Icons.delete))
                : Container(),

            // invite

            IconButton(
              icon: Icon(Icons.person_add),
              tooltip: "Invite a user",
              onPressed: () async {
                await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                          padding: const EdgeInsets.all(16),
                          child: StreamBuilder(
                            stream: FirebaseService().getFriends(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('No friends');
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Friends',
                                      style: TextStyle(fontSize: 20)),
                                  SizedBox(height: 16),
                                  ...snapshot.data!.map<Widget>((e) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(e
                                                .photoUrl ??
                                            'https://placehold.co/600x400/png'),
                                      ),
                                      title: Text(e.name),
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection('events')
                                            .doc(widget.eventId)
                                            .update({
                                          'subscribers':
                                              FieldValue.arrayUnion([e.id])
                                        });

                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ));
                    });
              },
            ),
          ],
        ),
        body: Column(children: [
          // event date
          // start time
          // end time
          // creator
          // subscribers

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // event date
                  /* Image.network(
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/schedule-app-jjmyyk/assets/qjsodqos36m8/no_image.jpg'),
                  */
                  SizedBox(height: 16),
                  Text(widget.event.eventTitle, style: TextStyle(fontSize: 24)),

                  Divider(),

                  StreamBuilder<List<SuperUser>>(
                    stream: _getSubscribers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No subscribers');
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subscribers', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 16),
                          ...snapshot.data!.map((e) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.photoUrl ??
                                    'https://placehold.co/600x400/png'),
                              ),
                              title: Text(e.name),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.event.subscribers
                          .contains(FirebaseAuth.instance.currentUser!.uid)) {
                        await _unsubscribeFromEvent();
                        setState(() {
                          widget.event.subscribers
                              .remove(FirebaseAuth.instance.currentUser!.uid);
                        });
                      } else {
                        await _subscribeToEvent();
                        setState(() {
                          widget.event.subscribers
                              .add(FirebaseAuth.instance.currentUser!.uid);
                        });
                      }
                    },
                    child: Text(widget.event.subscribers
                            .contains(FirebaseAuth.instance.currentUser!.uid)
                        ? 'Unsubscribe'
                        : 'Subscribe'),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
