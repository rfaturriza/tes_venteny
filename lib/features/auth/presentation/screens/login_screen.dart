import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tes_venteny/core/utils/extension/context_ext.dart';
import 'package:tes_venteny/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:tes_venteny/injection.dart';

import '../../../todo/presentation/screens/todos_screen.dart';
import '../../data/models/login_request_model.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth/login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => getIt<LoginBloc>()..add(const LoginEvent.getUser()),
      child: _LoginScaffold(),
    );
  }
}

class _LoginScaffold extends StatefulWidget {
  const _LoginScaffold();

  @override
  State<_LoginScaffold> createState() => __LoginScaffoldState();
}

class __LoginScaffoldState extends State<_LoginScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var isObscure = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is SuccessLogin) {
            Navigator.pushReplacementNamed(
              context,
              TodosScreen.routeName,
            );
          } else if (state is ErrorLogin) {
            context.showErrorToast(
              state.failure.message ?? 'Unknown error occurred',
            );
          }
        },
        builder: (context, state) {
          if (state is GettingUser) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Login',
                      style: context.theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                      ),
                      obscureText: isObscure,
                    ),
                    SizedBox(height: 20),
                    BlocConsumer<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is SuccessLogin) {
                          Navigator.pushReplacementNamed(
                            context,
                            TodosScreen.routeName,
                          );
                        } else if (state is ErrorLogin) {
                          context.showErrorToast(
                            state.failure.message ?? 'Unknown error occurred',
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is LoadingLogin) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: () {
                            context.read<LoginBloc>().add(
                                  LoginEvent.submit(
                                    requestModel: LoginRequestModel(
                                      username: _usernameController.text,
                                      password: _passwordController.text,
                                    ),
                                  ),
                                );
                          },
                          child: Text('Login'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
