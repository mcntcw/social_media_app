import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class PostEntity extends Equatable {
  final String id;
  final String contents;
  final DateTime createdAt;
  final MyUser author;
  final String picture;
  final List<Comment> comments;
  final List<String> likes;

  const PostEntity({
    required this.id,
    required this.contents,
    required this.createdAt,
    required this.author,
    required this.picture,
    required this.comments,
    required this.likes,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'contents': contents,
      'createdAt': createdAt,
      'author': author.id,
      'picture': picture,
      'comments': comments.map((comment) => comment.toEntity().toDocument()).toList(),
      'likes': likes,
    };
  }

  static PostEntity fromDocument(Map<String, dynamic> document) {
    return PostEntity(
      id: document['id'] as String,
      contents: document['contents'] as String,
      createdAt: DateTime.now(),
      author: MyUser(id: document['author'].toString(), email: '', name: ''),
      picture: document['picture'] as String,
      comments: (document['comments'] as List<dynamic>)
          .map((commentDoc) => Comment.fromEntity(CommentEntity.fromDocument(commentDoc)))
          .toList(),
      likes: (document['likes'] as List<dynamic>).map((likerId) => likerId as String).toList(),
    );
  }

  @override
  List<Object?> get props => [id, contents, author, picture, likes];
}
