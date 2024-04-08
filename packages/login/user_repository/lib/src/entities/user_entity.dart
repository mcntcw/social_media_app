import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? picture;
  final List<String> followers;
  final List<String> following;

  MyUserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    List<String>? followers,
    List<String>? following,
  })  : followers = followers ?? [],
        following = following ?? [];

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
      'followers': followers,
      'following': following,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> document) {
    return MyUserEntity(
      id: document['id'],
      email: document['email'],
      name: document['name'],
      picture: document['picture'] as String?,
      followers: (document['followers'] as List<dynamic>).map((followerId) => followerId as String).toList(),
      following: (document['following'] as List<dynamic>).map((followingId) => followingId as String).toList(),
    );
  }

  @override
  List<Object?> get props => [id, email, name, picture, followers, following];
}
