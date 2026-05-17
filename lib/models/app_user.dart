class AppUser {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final List<String> aliases;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.aliases,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      aliases: (json['aliases'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}