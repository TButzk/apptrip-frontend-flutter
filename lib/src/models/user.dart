class UserLogin {
  const UserLogin({
    required this.token,
    required this.name,
    required this.email,
    required this.favoritePlacesIds,
    required this.routeIds,
  });

  final String token;
  final String name;
  final String email;
  final List<String> favoritePlacesIds;
  final List<String> routeIds;

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      token: json['token'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      favoritePlacesIds: _stringListFromJson(json['favoritePlacesIds']),
      routeIds: _stringListFromJson(json['routeIds']),
    );
  }
}

class User {
  const User({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

List<String> _stringListFromJson(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<Object>().map((item) => item.toString()).toList();
}
