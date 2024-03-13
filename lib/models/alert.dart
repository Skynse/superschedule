enum AlertType {
  invite,
}

class Alert {
  String? id;
  final String title;
  final String? groupId;
  final String description;
  bool read = false;
  AlertType type = AlertType.invite;

  Alert({
    required this.title,
    required this.description,
    this.id,
    this.groupId,
    required this.read,
    required this.type,
  });

  Alert.fromMap(Map<String, dynamic> data, String id)
      : title = data['title'],
        description = data['description'],
        groupId = data['group_id'],
        id = id,
        read = data['read'],
        type = AlertType.invite;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'group_id': groupId,
      'read': false,
      'type': AlertType.invite.toString(),
    };
  }
}
