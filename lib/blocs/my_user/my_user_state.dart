part of 'my_user_bloc.dart';

enum MyUserStatus { process, success, failure }

class MyUserState extends Equatable {
  final MyUserStatus status;
  final MyUser? user;

  const MyUserState._({
    this.status = MyUserStatus.process,
    this.user,
  });

  const MyUserState.process() : this._();

  const MyUserState.success(MyUser user) : this._(status: MyUserStatus.success, user: user);

  const MyUserState.failure() : this._(status: MyUserStatus.failure);

  @override
  List<Object?> get props => [status, user];
}
