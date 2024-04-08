import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/edit_user_data/edit_user_data_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/utils/image_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:user_repository/user_repository_library.dart';

class SettingsScreen extends StatefulWidget {
  final MyUser user;
  const SettingsScreen({
    super.key,
    required this.user,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImageHandler imageHandler = ImageHandler();
  final TextEditingController editNameController = TextEditingController();

  bool isFirstLoad = true;
  bool usernameChanged = false;

  @override
  void initState() {
    super.initState();
    editNameController.text = widget.user.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
              Get.back();
            }),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: BlocBuilder<MyUserBloc, MyUserState>(
            builder: (context, state) {
              if (state.status == MyUserStatus.success) {
                return BlocListener<EditUserDataBloc, EditUserDataState>(
                  listener: (context, state) {
                    if (state is ChangeProfilePictureSuccess) {
                      context.read<MyUserBloc>().add(GetUserData(userId: context.read<MyUserBloc>().state.user!.id));
                    }
                    if (state is ChangeUsernameSuccess) {
                      setState(() {
                        usernameChanged = true;
                      });
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await imageHandler.uploadProfilePicture(context, state.user!.id);
                              },
                              child: Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        image: DecorationImage(
                                          image: state.user?.picture == null || state.user?.picture == ""
                                              ? const AssetImage('assets/images/logo.png')
                                              : NetworkImage(state.user!.picture.toString()) as ImageProvider<Object>,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Image.asset(
                                        'assets/images/photo.png',
                                        height: 32,
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              style: TextStyle(
                                fontSize: 22,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              textAlign: TextAlign.center,
                              controller: editNameController,
                              maxLines: 1,
                              maxLength: 150,
                              onChanged: (value) {
                                setState(() {
                                  usernameChanged = false;
                                });
                              },
                              decoration: InputDecoration(
                                fillColor: Theme.of(context).colorScheme.surface,
                                //  filled: true,
                                counterText: "",
                                hintText: "",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<EditUserDataBloc>().add(ChangeUsername(
                                    editNameController.text.toLowerCase(),
                                    context.read<AuthenticationBloc>().state.user!.uid));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: usernameChanged == true
                                      ? Colors.greenAccent
                                      : Theme.of(context).colorScheme.onBackground,
                                ),
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state.status == MyUserStatus.process) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                );
              } else {
                return const Center(
                  child: Text('Error'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
