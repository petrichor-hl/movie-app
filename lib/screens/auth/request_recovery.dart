import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/utils/validate_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestRecovery extends StatefulWidget {
  const RequestRecovery({super.key});

  @override
  State<RequestRecovery> createState() => _RequestRecoveryState();
}

class _RequestRecoveryState extends State<RequestRecovery> {
  final _emailController = TextEditingController();
  final _pageController = PageController(initialPage: 0);

  bool _isProcessing = false;

  void _submit() async {
    final enteredEmail = _emailController.text;

    setState(() {
      _isProcessing = true;
    });

    try {
      await supabase.auth.resetPasswordForEmail(
        enteredEmail,
        redirectTo: 'http://localhost:56441/#/reset-password',
      );

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
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

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Hero(
          tag: 'NetflixLogo',
          child: Image.asset(
            Assets.viovidLogo,
            width: 140,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Nhập Email
          buildFirstPage(),
          // Xác nhận đã gửi Email khôi phục mật khẩu
          buidSecondPage(),
        ],
      ),
    );
  }

  Widget buildFirstPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StatefulBuilder(builder: (ctx, setStateColumn) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Khôi phục mật khẩu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const Gap(20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 51, 51, 51),
                hintText: 'Email của bạn',
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
              onChanged: (_) => setStateColumn(() {}),
            ),
            const Gap(30),
            _isProcessing
                ? const Align(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: validateEmail(_emailController.text) ? _submit : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        disabledBackgroundColor: const Color(0xAA333333),
                        disabledForegroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'XÁC NHẬN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            const Gap(50),
          ],
        );
      }),
    );
  }

  Widget buidSecondPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nếu có tài khoản tồn tại với email ${_emailController.text},\nbạn sẽ nhận được email hướng dẫn khôi phục mật khẩu.\n\nNếu nó không xuất hiện, vui lòng kiểm tra thư mục spam',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(30),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF18BDFA),
            ),
            child: const Text(
              'Trở về trang đăng nhập',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(30),
        ],
      ),
    );
  }
}
