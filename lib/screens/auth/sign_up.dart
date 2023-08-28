import 'package:flutter/material.dart';
import 'package:movie_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignInState();
}

class _SignInState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameControllber = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isProcessing = false;

  void _signUpAccount() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final enteredEmail = _emailController.text;
    final enteredPassword = _passwordController.text;

    try {
      await supabase.auth.signUp(
        email: enteredEmail,
        password: enteredPassword,
        emailRedirectTo: 'io.supabase.movie-app://login-callback/',
        data: {
          'full_name': 'Tran Le Hoang Lam',
          'avatar_url': 'https://i.imgur.com/zBr1CQ3.png',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực Email trong Hộp thư đến.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Có lỗi xảy ra, vui lòng thử lại.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameControllber.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chưa hoàn thành',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 51, 51, 51),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Color(0xFFACACAC)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                ),
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                enableSuggestions: false, // No work
                keyboardType:
                    TextInputType.emailAddress, // Trick: disable suggestions
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bạn chưa nhập Email';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 12,
              ),
              _PasswordTextField(passwordController: _passwordController),
              const SizedBox(
                height: 20,
              ),
              _isProcessing
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _signUpAccount,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'ĐĂNG KÝ',
                          style: TextStyle(fontWeight: FontWeight.bold),
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

class _PasswordTextField extends StatefulWidget {
  const _PasswordTextField({required this.passwordController});
  final TextEditingController passwordController;

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isShowPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 51, 51, 51),
        hintText: 'Mật khẩu',
        hintStyle: const TextStyle(color: Color(0xFFACACAC)),
        suffixIcon: widget.passwordController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    _isShowPassword = !_isShowPassword;
                  });
                },
                icon: _isShowPassword
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
              ),
        suffixIconColor: const Color(0xFFACACAC),
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      ),
      obscureText: !_isShowPassword,
      style: const TextStyle(color: Colors.white),
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bạn chưa nhập Mật khẩu';
        }
        if (value.length < 6) {
          return 'Mật khẩu gồm 6 ký tự trở lên.';
        }
        return null;
      },
      onChanged: (value) {
        if (value.isEmpty) {
          _isShowPassword = false;
        }

        if (value.length <= 1) setState(() {});
      },
    );
  }
}
