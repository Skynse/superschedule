class Alert {
  String? id;
  final String title;
  final String description;
  final bool read = false;

  Alert({
    required this.title,
    required this.description,
    this.id,
  });

  Alert.fromMap(Map<String, dynamic> data, String id)
      : title = data['title'],
        description = data['description'],
        id = id;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'read': false,
    };
  }
}
