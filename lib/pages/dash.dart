import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scheduleup/models/event.dart';
import 'package:scheduleup/pages/createEvent.dart';
import 'package:scheduleup/pages/eventView.dart';
import 'package:scheduleup/pages/friends.dart';
import 'package:scheduleup/pages/groups.dart';
import 'package:scheduleup/pages/profile.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

String calculateTimeAway(DateTime eventDate) {
  var now = DateTime.now();
  var difference = eventDate.difference(now);
  var days = difference.inDays;
  var hours = difference.inHours;
  var minutes = difference.inMinutes;

  if (days > 0) {
    return '$days days away';
  } else if (hours > 0) {
    return '$hours hours away';
  } else if (minutes > 0) {
    return '$minutes minutes away';
  } else {
    return 'happening now';
  }
}

class _DashboardState extends State<Dashboard> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  var pages = [
    EventListView(),
    FriendsList(),
    GroupsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        unselectedIconTheme:
            IconThemeData(color: Theme.of(context).iconTheme.color),
        selectedIconTheme: IconThemeData(color: Theme.of(context).splashColor),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class EventListView extends ConsumerStatefulWidget {
  const EventListView({Key? key}) : super(key: key);

  @override
  ConsumerState<EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends ConsumerState<EventListView> {
  Widget buildNoEvents() {
    return const Center(
      child: Text('No events found'),
    );
  }

  Widget buildEventCard(Event event, String id) {
    return Card(
      child: ListTile(
        title: Text(event.eventTitle),
        isThreeLine: true,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMd().format(event.eventDate)),
            Text(
                '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'),
          ],
        ),
        // third

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventView(
                event: event,
                eventId: id,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: Container(
          child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('events')
                .where('subscribers',
                    arrayContains: FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.data!.docs.isEmpty || !snapshot.hasData) {
                return const Center(
                  child: Text('No alerts found'),
                );
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['title']),
                    subtitle: Text(
                        "Event ${data['title']} is ${calculateTimeAway(data['date'].toDate())}"),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.data!.docs.isEmpty || !snapshot.hasData) {
            return buildNoEvents();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return buildEventCard(
                  Event.fromMap(data, document.id), document.id);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic here for the FAB action
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
