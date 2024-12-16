import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/Implemention/Auth.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _loginUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        ModalRoute.withName(logInScreenRoute));
  }
  void signInUser() {
    if (_formKey.currentState!.validate()) {
      authService.signInUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );
      _loginUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login_dark.png",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your data that you intered during your registration.",
                  ),
                  const SizedBox(height: defaultPadding),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onSaved: (emal) {
                            // Email
                          },
                          controller: _emailController,
                          validator: emaildValidator.call,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email address",
                            prefixIcon: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                              child: SvgPicture.asset(
                                "assets/icons/Message.svg",
                                height: 24,
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.3),
                                    BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          onSaved: (pass) {
                            // Password

                          },
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                              child: SvgPicture.asset(
                                "assets/icons/Lock.svg",
                                height: 24,
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.3),
                                    BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    child: TextButton(
                      child: const Text("Forgot password"),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, passwordRecoveryScreenRoute);
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height > 700
                        ? size.height * 0.1
                        : defaultPadding,
                  ),
                  ElevatedButton(
                    onPressed: signInUser,
                    child: const Text("Log in"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
