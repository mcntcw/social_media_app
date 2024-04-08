import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';

class CommentEntity extends Equatable {
  final String id;
  final String contents;
  final DateTime createdAt;
  final MyUser author;
  final List<String> likes;

  const CommentEntity({
    required this.id,
    required this.contents,
    required this.createdAt,
    required this.author,
    required this.likes,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'contents': contents,
      'createdAt': createdAt,
      'author': author.toEntity().toDocument(),
      'likes': likes,
    };
  }

  static CommentEntity fromDocument(Map<String, dynamic> document) {
    return CommentEntity(
      id: document['id'] as String,
      contents: document['contents'] as String,
      createdAt: DateTime.now(),
      author: MyUser.fromEntity(MyUserEntity.fromDocument(document['author'])),
      likes: (document['likes'] as List<dynamic>).map((likerId) => likerId as String).toList(),
    );
  }

  @override
  List<Object?> get props => [id, contents, author];
}
