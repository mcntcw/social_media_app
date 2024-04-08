import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

abstract class PostRepository {
  Future<Post> createPost(Post post, String file);
  Future<void> editPost(Post post, String editedContent);
  Future<void> deletePost(Post post);
  Future<List<Post>> getPosts();
  Future<Comment> addCommentToPost(Post post, Comment comment);
  Future<void> deleteCommentFromPost(Post post, Comment comment);
  Future<void> likePost(Post post, String userId);
  Future<void> likeComment(Post post, Comment comment, String userId);
  Future<List<MyUser>> getLikes(Post post);
  Future<List<MyUser>> getCommentLikes(Post post, Comment comment);
}
