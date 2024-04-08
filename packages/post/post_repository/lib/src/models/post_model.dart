import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class Post {
  String id;
  String contents;
  DateTime createdAt;
  MyUser author;
  String picture;
  List<Comment> comments;
  List<String> likes;

  Post({
    required this.id,
    required this.contents,
    required this.createdAt,
    required this.author,
    required this.picture,
    required this.comments,
    required this.likes,
  });

  static final empty = Post(
    id: '',
    contents: '',
    createdAt: DateTime(0),
    author: MyUser.empty,
    picture: '',
    comments: [],
    likes: [],
  );

  Post copyWith(
      {String? id,
      String? contents,
      DateTime? createdAt,
      MyUser? author,
      String? picture,
      List<Comment>? comments,
      List<String>? likes}) {
    return Post(
      id: id ?? this.id,
      contents: contents ?? this.contents,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      picture: picture ?? this.picture,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      contents: contents,
      createdAt: createdAt,
      author: author,
      picture: picture,
      comments: comments,
      likes: likes,
    );
  }

  static Post fromEntity(PostEntity entity) {
    return Post(
      id: entity.id,
      contents: entity.contents,
      createdAt: entity.createdAt,
      author: entity.author,
      picture: entity.picture,
      comments: entity.comments,
      likes: entity.likes,
    );
  }
}
