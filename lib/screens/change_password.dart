import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _changePassword() async {
    // print("Old Password: " + profileData['password']);
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );
    } on AuthException catch (e) {
      print(e.message);
    }

    await supabase.from('profile').update(
      {
        'password': _newPasswordController.text,
      },
    ).eq('id', supabase.auth.currentUser!.id);

    profileData['password'] = _newPasswordController.text;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    }

    setState(() {
      _isProcessing = false;
    });

    // final verifyOldPassword = profileData['password'] == _oldPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 51, 51, 51),
                  hintText: 'Mật khẩu cũ',
                  hintStyle: TextStyle(color: Color(0xFFACACAC)),
                  suffixIconColor: Color(0xFFACACAC),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  errorStyle: TextStyle(fontSize: 14),
                ),
                obscureText: /*!_isShowPassword*/ true,
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bạn chưa nhập Mật khẩu cũ';
                  }
                  if (value != profileData['password']) {
                    return 'Mật khẩu cũ không đúng.';
                  }
                  return null;
                },
              ),
              const Gap(30),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 51, 51, 51),
                  hintText: 'Mật khẩu mới',
                  hintStyle: TextStyle(color: Color(0xFFACACAC)),
                  suffixIconColor: Color(0xFFACACAC),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  errorStyle: TextStyle(fontSize: 14),
                ),
                obscureText: /*!_isShowPassword*/ true,
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bạn chưa nhập Mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu gồm 6 ký tự trở lên.';
                  }
                  if (_oldPasswordController.text == profileData['password'] &&
                      value == profileData['password']) {
                    return 'Mật khẩu mới không được trùng với mật khẩu cũ.';
                  }
                  return null;
                },
                // onChanged: (value) {
                //   if (value.isEmpty) {
                //     _isShowPassword = false;
                //   }
                //   if (value.length <= 1) setState(() {});
                // },
              ),
              const Gap(10),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 51, 51, 51),
                  hintText: 'Xác nhận Mật khẩu mới',
                  hintStyle: TextStyle(color: Color(0xFFACACAC)),
                  suffixIconColor: Color(0xFFACACAC),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  errorStyle: TextStyle(fontSize: 14),
                ),
                obscureText: /*!_isShowPassword*/ true,
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bạn chưa xác nhận Mật khẩu mới';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const Gap(40),
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
                        onPressed: _changePassword,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'ĐỔI MẬT KHẨU',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              Gap(MediaQuery.sizeOf(context).height * 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
