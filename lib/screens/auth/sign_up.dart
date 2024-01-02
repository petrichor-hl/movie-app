import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/utils/common_variables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignInState();
}

class _SignInState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameControllber = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isProcessing = false;

  String _errorText = '';

  void _signUpAccount() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _errorText = '';

    setState(() {
      _isProcessing = true;
    });

    final enteredUsername = _usernameControllber.text;
    final enteredDob = _dobController.text;
    final enteredEmail = _emailController.text;
    final enteredPassword = _passwordController.text;

    // print(_dobController.text);

    try {
      final List<Map<String, dynamic>> checkDuplicate =
          await supabase.from('profile').select('email').eq('email', enteredEmail);

      if (checkDuplicate.isEmpty) {
        await supabase.auth.signUp(
          email: enteredEmail,
          password: enteredPassword,
          emailRedirectTo: 'http://localhost:56441/#/cofirmed-sign-up',
          data: {
            'email': enteredEmail,
            'password': enteredPassword,
            'full_name': enteredUsername,
            'dob': enteredDob,
            'avatar_url': 'default_avt.png',
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
      } else {
        _errorText = 'Email $enteredEmail đã tồn tại.';
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

  Future<void> _openDatePicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (chosenDate != null) {
      _dobController.text = vnDateFormat.format(chosenDate);
    }
  }

  @override
  void dispose() {
    _usernameControllber.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(screenSize.height * 0.07),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 51, 51, 51),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.network(
                      'https://kpaxjjmelbqpllxenpxz.supabase.co/storage/v1/object/public/avatar/default_avt.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      frameBuilder: (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (wasSynchronouslyLoaded) {
                          return child;
                        }
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(
                              milliseconds: 500), // Adjust the duration as needed
                          curve: Curves.easeInOut,
                          child: child, // Adjust the curve as needed
                        );
                      },
                      // https://api.flutter.dev/flutter/widgets/Image/loadingBuilder.html
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        // print("loadingProgress: $loadingProgress");
                        return Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              // value: loadingProgress.expectedTotalBytes != null
                              //     ? loadingProgress.cumulativeBytesLoaded /
                              //         loadingProgress.expectedTotalBytes!
                              //     : null,
                              color: Theme.of(context).colorScheme.primary,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 48,
                      width: 48,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: const Icon(
                        Icons.image_rounded,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              const Gap(8),
              const Text(
                'Sau khi đăng nhập ',
                style: TextStyle(
                  color: Color(0xFFACACAC),
                  fontSize: 15,
                ),
              ),
              const Text(
                'Bạn có thể thay đổi Ảnh đại diện.',
                style: TextStyle(
                  color: Color(0xFFACACAC),
                  fontSize: 15,
                ),
              ),
              const Gap(24),
              TextFormField(
                controller: _usernameControllber,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 51, 51, 51),
                  hintText: 'Tên của bạn',
                  hintStyle: TextStyle(color: Color(0xFFACACAC)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  errorStyle: TextStyle(fontSize: 14),
                ),
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                enableSuggestions: false, // No work+
                keyboardType: TextInputType.emailAddress, // Trick: disable suggestions
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bạn chưa nhập Tên';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 12,
              ),
              GestureDetector(
                onTap: () => _openDatePicker(context),
                child: TextFormField(
                  controller: _dobController,
                  enabled: false,
                  mouseCursor: SystemMouseCursors.click,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 51, 51, 51),
                    hintText: 'dd/MM/yyyy',
                    hintStyle: TextStyle(color: Color(0xFFACACAC)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    suffixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.edit_calendar,
                        color: Color(0xFFACACAC),
                      ),
                    ),
                    errorStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bạn chưa nhập Ngày sinh'; // 68 44
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              // _DobTextFormField(dobController: _dobController),
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
                  errorStyle: TextStyle(fontSize: 14),
                ),
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                enableSuggestions: false, // No work
                keyboardType: TextInputType.emailAddress, // Trick: disable suggestions
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
              _PasswordTextFormField(passwordController: _passwordController),
              const Gap(50),

              if (_errorText.isNotEmpty) ...[
                Text(
                  _errorText,
                  style: errorTextStyle(
                    context,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(12),
              ],
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

class _PasswordTextFormField extends StatefulWidget {
  const _PasswordTextFormField({required this.passwordController});
  final TextEditingController passwordController;

  @override
  State<_PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<_PasswordTextFormField> {
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
        errorStyle: const TextStyle(fontSize: 14),
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
