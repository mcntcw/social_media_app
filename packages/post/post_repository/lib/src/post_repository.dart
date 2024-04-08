import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';
import 'package:uuid/uuid.dart';

class FirebasePostRepository implements PostRepository {
  final postsCollection = FirebaseFirestore.instance.collection('posts');
  final usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Future<Post> createPost(Post post, String? file) async {
    try {
      post.id = const Uuid().v1();
      if (file == null || file == '') {
        post.picture = '';
      } else {
        File imageFile = File(file.toString());
        Reference firebaseStoreRef =
            FirebaseStorage.instance.ref().child('${post.author.id}/posts/${post.id}/post_image');
        await firebaseStoreRef.putFile(
          imageFile,
        );
        String url = await firebaseStoreRef.getDownloadURL();
        post.picture = url;
      }

      post.createdAt = DateTime.now();
      await postsCollection.doc(post.id).set(post.toEntity().toDocument());
      return post;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> editPost(Post post, String editedContent) async {
    try {
      final postDoc = await postsCollection.doc(post.id).get();
      if (postDoc.exists) {
        await postsCollection.doc(post.id).update({
          'contents': editedContent,
        });
      } else {
        throw Exception('Post with id ${post.id} not found.');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deletePost(Post post) async {
    try {
      await postsCollection.doc(post.id).delete();
      if (post.picture.isNotEmpty) {
        Reference firebaseStoreRef =
            FirebaseStorage.instance.ref().child('${post.author.id}/posts/${post.id}/post_image');
        await firebaseStoreRef.delete();
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Post>> getPosts() async {
    try {
      final postsData = await postsCollection.get();
      List<Post> posts = await Future.wait(postsData.docs.map((e) async {
        final post = Post.fromEntity(PostEntity.fromDocument(e.data()));
        post.createdAt = (e.data())['createdAt'].toDate();
        final postDoc = await postsCollection.doc(post.id).get();
        if (postDoc.exists) {
          final postMap = postDoc.data() as Map<String, dynamic>;
          if (postMap.containsKey('comments')) {
            final commentsData = postMap['comments'];
            if (commentsData != null && commentsData is List) {
              List<Comment> comments = await Future.wait(commentsData.map(
                (commentData) async {
                  Comment comment = Comment.fromEntity(CommentEntity.fromDocument(commentData));
                  comment.createdAt = (commentData)['createdAt'].toDate();

                  final commentAuthorData = await usersCollection.doc(comment.author.id).get();
                  comment.author.picture = commentAuthorData.get('picture');
                  comment.author.name = commentAuthorData.get('name');

                  return comment;
                },
              ));

              comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              post.comments = comments;
            }
          }
        }

        final userData = await usersCollection.doc(post.author.id).get();
        post.author.picture = userData.get('picture');
        post.author.name = userData.get('name');

        return post;
      }));

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Comment> addCommentToPost(Post post, Comment comment) async {
    try {
      comment.id = const Uuid().v1();
      comment.createdAt = DateTime.now();

      final commentDocument = comment.toEntity().toDocument();

      await postsCollection.doc(post.id).update({
        'comments': FieldValue.arrayUnion([commentDocument]),
      });

      return comment;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteCommentFromPost(Post post, Comment comment) async {
    try {
      log(post.id);

      await postsCollection.doc(post.id).update({
        'comments': FieldValue.arrayRemove([comment.toEntity().toDocument()]),
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> likePost(Post post, String userId) async {
    try {
      final postDoc = await postsCollection.doc(post.id).get();
      if (postDoc.exists) {
        final postMap = postDoc.data() as Map<String, dynamic>;
        if (postMap.containsKey('likes')) {
          List<dynamic> likesData = postMap['likes'];

          if (likesData.any((likerId) => likerId == userId)) {
            await postsCollection.doc(post.id).update({
              'likes': FieldValue.arrayRemove([userId]),
            });
            post.likes.remove(userId);
          } else {
            await postsCollection.doc(post.id).update({
              'likes': FieldValue.arrayUnion([userId]),
            });
            post.likes.add(userId);
          }
        }
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MyUser>> getLikes(Post post) async {
    try {
      final postDoc = await postsCollection.doc(post.id).get();
      if (postDoc.exists) {
        final postData = postDoc.data();

        if (postData is Map<String, dynamic>) {
          final postMap = postData;

          if (postMap.containsKey('likes')) {
            final likesData = postMap['likes'];

            if (likesData != null && likesData is List) {
              List<String> likerIds = List<String>.from(likesData);

              List<MyUser> likes = await Future.wait(likerIds.map(
                (likerId) async {
                  final likerDoc = await usersCollection.doc(likerId).get();

                  if (likerDoc.exists) {
                    MyUser liker = MyUser(
                      id: likerId,
                      name: likerDoc.get('name') ?? '',
                      email: likerDoc.get('email') ?? '',
                      picture: likerDoc.get('picture'),
                      followers: (likerDoc.get('followers') as List<dynamic>).cast<String>(),
                      following: (likerDoc.get('following') as List<dynamic>).cast<String>(),
                    );
                    return liker;
                  } else {
                    return MyUser.empty;
                  }
                },
              ));
              return likes;
            }
          }
        }
      }

      return [];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> likeComment(Post post, Comment comment, String userId) async {
    try {
      final postDoc = await postsCollection.doc(post.id).get();
      if (postDoc.exists) {
        final postMap = postDoc.data() as Map<String, dynamic>;
        if (postMap.containsKey('comments')) {
          List<dynamic> commentsData = postMap['comments'];

          final updatedComments = commentsData.map((commentData) {
            final Map<String, dynamic> commentMap = commentData;

            if (commentMap['id'] == comment.id) {
              List<dynamic> likesData = commentMap['likes'] ?? [];

              if (likesData.contains(userId)) {
                likesData.remove(userId);
              } else {
                likesData.add(userId);
              }

              return {
                ...commentMap,
                'likes': likesData,
              };
            }
            return commentMap;
          }).toList();

          await postsCollection.doc(post.id).update({
            'comments': updatedComments,
          });
        }
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MyUser>> getCommentLikes(Post post, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(post.id).get();
      if (postDoc.exists) {
        final postData = postDoc.data();

        if (postData is Map<String, dynamic>) {
          final postMap = postData;

          if (postMap.containsKey('comments')) {
            List<dynamic> commentsData = postMap['comments'];

            final commentData = commentsData.firstWhere(
              (commentData) {
                final Map<String, dynamic> commentMap = commentData;
                return commentMap['id'] == comment.id;
              },
              orElse: () => null,
            );

            if (commentData != null && commentData is Map<String, dynamic>) {
              final commentMap = commentData;

              if (commentMap.containsKey('likes')) {
                final likesData = commentMap['likes'];

                if (likesData != null && likesData is List) {
                  List<String> likerIds = List<String>.from(likesData);

                  List<MyUser> likes = await Future.wait(likerIds.map(
                    (likerId) async {
                      final likerDoc = await usersCollection.doc(likerId).get();

                      if (likerDoc.exists) {
                        MyUser liker = MyUser(
                          id: likerId,
                          name: likerDoc.get('name') ?? '',
                          email: likerDoc.get('email') ?? '',
                          picture: likerDoc.get('picture'),
                          followers: (likerDoc.get('followers') as List<dynamic>).cast<String>(),
                          following: (likerDoc.get('following') as List<dynamic>).cast<String>(),
                        );
                        return liker;
                      } else {
                        return MyUser.empty;
                      }
                    },
                  ));

                  return likes;
                }
              }
            }
          }
        }
      }

      return [];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
