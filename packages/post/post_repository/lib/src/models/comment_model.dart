import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class Comment {
  String id;
  String contents;
  DateTime createdAt;
  MyUser author;
  List<String> likes;
  Comment({
    required this.id,
    required this.contents,
    required this.createdAt,
    required this.author,
    required this.likes,
  });

  static final empty = Comment(
    id: '',
    contents: '',
    createdAt: DateTime(0),
    author: MyUser.empty,
    likes: [],
  );

  Comment copyWith({String? id, String? contents, DateTime? createdAt, MyUser? author, List<String>? likes}) {
    return Comment(
      id: id ?? this.id,
      contents: contents ?? this.contents,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      likes: likes ?? this.likes,
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(id: id, contents: contents, createdAt: createdAt, author: author, likes: likes);
  }

  static Comment fromEntity(CommentEntity entity) {
    return Comment(
        id: entity.id,
        contents: entity.contents,
        createdAt: entity.createdAt,
        author: entity.author,
        likes: entity.likes);
  }
}
