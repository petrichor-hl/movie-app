import 'package:flutter/material.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/auth/request_recovery.dart';
import 'package:movie_app/utils/common_variables.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<SignInScreen> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isProcessing = false;

  void _submit() async {
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
      await supabase.auth.signInWithPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        if (error.message == "Invalid login credentials") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tên đăng nhập hoặc mật khẩu sai'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Có lỗi xảy ra, vui lòng thử lại.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }

    // Không setState _isProcessing = false; khi loggin thành công vì:
    // Sau khi loggin, thì phải fetch data cho tài khoản
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  errorStyle: TextStyle(
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                ),
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                enableSuggestions: false, // No work
                keyboardType: TextInputType.emailAddress, // Trick: disable suggestions
                validator: (value) {
                  // print('Value = $value');
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
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 16,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageTransition(
                      child: const RequestRecovery(),
                      type: PageTransitionType.fade,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    'Khôi phục mật khẩu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bạn chưa có tài khoản? ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear,
                      );
                    },
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(
                          color: primaryColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
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
        errorStyle: const TextStyle(
          fontSize: 14,
        ),
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
