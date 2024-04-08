import 'package:equatable/equatable.dart';
import 'package:user_repository/src/entities/entities.dart';

// ignore: must_be_immutable
class MyUser extends Equatable {
  final String id;
  final String email;
  String name;
  String? picture;
  List<String> followers;
  List<String> following;

  MyUser({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    List<String>? followers,
    List<String>? following,
  })  : followers = followers ?? [],
        following = following ?? [];

  static final empty = MyUser(
    id: '',
    email: '',
    name: '',
    picture: '',
    followers: const [],
    following: const [],
  );

  MyUser copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    List<String>? followers,
    List<String>? following,
  }) {
    return MyUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        picture: picture ?? this.picture,
        followers: followers ?? this.followers,
        following: following ?? this.following);
  }

  MyUserEntity toEntity() {
    return MyUserEntity(
      id: id,
      email: email,
      name: name,
      picture: picture,
      followers: followers,
      following: following,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      picture: entity.picture,
      followers: entity.followers,
      following: entity.following,
    );
  }

  @override
  List<Object?> get props => [id, email, name, picture, followers, following];
}
