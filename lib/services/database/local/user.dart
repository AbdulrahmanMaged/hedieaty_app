class User {
  final String? id;
  final String name;
  final String email;
  final String? preferences;

  User({this.id, required this.name, required this.email, this.preferences});

  // Convert a User object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }

  // Convert a Map into a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'],
    );
  }
}
