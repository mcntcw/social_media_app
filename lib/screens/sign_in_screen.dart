import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/sign_in/sign_in_bloc.dart';
import 'package:social_media_app/blocs/sign_up/sign_up_bloc.dart';
import 'package:social_media_app/screens/sign_up_screen.dart';
import 'package:social_media_app/widgets/form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  bool obscurePassword = true;
  String? _errorMessage;
  String? _signInMessage;
  IconData iconPassword = Icons.remove_red_eye;
  bool signInSuccess = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "SOMA",
                      style: TextStyle(
                        fontFamily: 'Mantranaga',
                        fontSize: 44,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'Sign in to your account',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      border: Border.all(width: 3, color: Theme.of(context).colorScheme.onBackground),
                      borderRadius:
                          const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                  child: BlocListener<SignInBloc, SignInState>(
                    listener: (context, state) {
                      if (state is SignInSuccess) {
                        setState(() {
                          signInRequired = false;
                        });
                      } else if (state is SignInProcess) {
                        setState(() {
                          signInSuccess = false;
                          signInRequired = true;
                        });
                      } else if (state is SignInFailure) {
                        setState(() {
                          if (state.message == "INVALID_LOGIN_CREDENTIALS" || state.message == "invalid-credential") {
                            _signInMessage = "Invalid email or password";
                          }
                          if (state.message == "too-many-requests") {
                            _signInMessage = "Too many requests, try again later";
                          }
                          signInSuccess = false;
                          signInRequired = false;
                        });
                      }
                    },
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            ),
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
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<SignInBloc>().add(
                                      SignInRequired(emailController.text, passwordController.text),
                                    );
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
                                  'Sign in',
                                  style: TextStyle(color: Theme.of(context).colorScheme.background),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          signInSuccess == false && signInRequired == false && _signInMessage != null
                              ? Text(
                                  _signInMessage.toString(),
                                  style: TextStyle(fontSize: 16, color: Colors.redAccent.withOpacity(0.8)),
                                )
                              : const Text('', style: TextStyle(fontSize: 16, color: Colors.transparent)),
                          signInRequired == true
                              ? CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.onBackground,
                                )
                              : Container(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Haven't got account yet?",
                                  style: TextStyle(
                                    fontFamily: 'InterRegular',
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    getx.Get.to(
                                        () => BlocProvider(
                                              create: (context) => SignUpBloc(
                                                  userRepository: context.read<AuthenticationBloc>().userRepository),
                                              child: const SignUpScreen(),
                                            ),
                                        transition: getx.Transition.cupertino,
                                        duration: const Duration(milliseconds: 750));
                                  },
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                      fontFamily: 'InterBold',
                                      fontSize: 20,
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
