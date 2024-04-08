import 'package:social_media_app/blocs/sign_up/sign_up_bloc.dart';
import 'package:social_media_app/widgets/form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:user_repository/user_repository_library.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  String? _signUpMessage;
  String? _errorMessage;
  IconData iconPassword = Icons.remove_red_eye;
  bool signUpRequired = false;
  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;
  bool signUpSuccess = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Sign up',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onBackground,
              size: 24,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: BlocListener<SignUpBloc, SignUpState>(
              listener: (context, state) {
                if (state is SignUpSuccess) {
                  setState(() {
                    Get.back();
                  });
                } else if (state is SignUpProcess) {
                  setState(() {
                    signUpRequired = true;
                  });
                } else if (state is SignUpFailure) {
                  setState(() {
                    if (state.message == "email-already-in-use") {
                      _signUpMessage = "This email is already in use, try another one";
                    }
                    signUpRequired = false;
                  });
                }
              },
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/lock.png',
                      height: 80,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: nameController,
                      hintText: 'Name',
                      obscureText: false,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icon(
                        Icons.person_2_rounded,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (val.length > 30) {
                          return 'Name too long';
                        } else if (!RegExp(r'^[a-zA-Z0-9._]*$').hasMatch(val)) {
                          return 'Please use only letters, numbers, dots and underscores';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    FormTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                      errorMessage: _errorMessage,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    FormTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icon(Icons.lock, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                      errorMessage: _errorMessage,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                            .hasMatch(val)) {
                          return 'Please enter a valid password';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                            if (obscurePassword) {
                              iconPassword = Icons.remove_red_eye;
                            } else {
                              iconPassword = Icons.remove_red_eye_outlined;
                            }
                          });
                        },
                        icon: Icon(
                          iconPassword,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                      onChanged: (val) {
                        if (val!.contains(RegExp(r'[A-Z]'))) {
                          setState(() {
                            containsUpperCase = true;
                          });
                        } else {
                          setState(() {
                            containsUpperCase = false;
                          });
                        }
                        if (val.contains(RegExp(r'[a-z]'))) {
                          setState(() {
                            containsLowerCase = true;
                          });
                        } else {
                          setState(() {
                            containsLowerCase = false;
                          });
                        }
                        if (val.contains(RegExp(r'[0-9]'))) {
                          setState(() {
                            containsNumber = true;
                          });
                        } else {
                          setState(() {
                            containsNumber = false;
                          });
                        }
                        if (val.contains(RegExp(r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
                          setState(() {
                            containsSpecialChar = true;
                          });
                        } else {
                          setState(() {
                            containsSpecialChar = false;
                          });
                        }
                        if (val.length >= 8) {
                          setState(() {
                            contains8Length = true;
                          });
                        } else {
                          setState(() {
                            contains8Length = false;
                          });
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "1 uppercase",
                              style: TextStyle(
                                  color: containsUpperCase
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onBackground),
                            ),
                            Text(
                              "1 lowercase",
                              style: TextStyle(
                                  color: containsLowerCase
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onBackground),
                            ),
                            Text(
                              "1 number",
                              style: TextStyle(
                                  color: containsNumber
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onBackground),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "1 special character",
                              style: TextStyle(
                                  color: containsSpecialChar
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onBackground),
                            ),
                            Text(
                              "8 minimum character",
                              style: TextStyle(
                                  color: contains8Length
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onBackground),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          MyUser myUser = MyUser.empty;
                          myUser =
                              myUser.copyWith(email: emailController.text, name: nameController.text.toLowerCase());
                          setState(() {
                            context.read<SignUpBloc>().add(SignUpRequired(myUser, passwordController.text));
                          });

                          Future<void> backAfterSignUp() async {
                            if (signUpSuccess == true) {
                              await Future.delayed(const Duration(seconds: 2));
                              Get.back();
                            }
                          }

                          backAfterSignUp();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onBackground,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Sign up',
                            style: TextStyle(color: Theme.of(context).colorScheme.background),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    signUpRequired == false && _signUpMessage != null
                        ? Text(
                            _signUpMessage.toString(),
                            style: TextStyle(fontSize: 16, color: Colors.redAccent.withOpacity(0.8)),
                          )
                        : const Text('', style: TextStyle(fontSize: 16, color: Colors.transparent)),
                    signUpRequired == true
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onBackground,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
