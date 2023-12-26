import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/onboarding/onboarding.dart';
import 'package:movie_app/screens/change_password.dart';
import 'package:movie_app/screens/my_list_films.dart';
import 'package:movie_app/screens/update_user_info.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:movie_app/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final StreamSubscription<AuthState> _authSubscription;

  void _clearGlobalDataOfUser() {
    profileData.clear();
    downloadedFilms.clear();
    // TODO: delete all downloaded film
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session == null) {
        _clearGlobalDataOfUser();
        Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            child: const OnboardingScreen(),
            type: PageTransitionType.fade,
            duration: 800.ms,
            settings: const RouteSettings(name: '/onboarding'),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Header(),
            _ProfileSettingItem(
              title: 'Đổi mật khẩu',
              iconData: Icons.password_rounded,
              onTap: () {
                context.read<RouteStackCubit>().push('/change_password');
                Navigator.of(context)
                    .push(
                      PageTransition(
                        child: const ChangePasswordScreen(),
                        type: PageTransitionType.rightToLeft,
                        duration: 300.ms,
                        reverseDuration: 300.ms,
                        settings: const RouteSettings(name: '/change_password'),
                      ),
                    )
                    .then((_) => context.read<RouteStackCubit>().pop());
              },
            ),
            _ProfileSettingItem(
              title: 'Danh sách',
              iconData: Icons.list,
              onTap: () {
                context.read<RouteStackCubit>().push('/my_list_films');
                context.read<RouteStackCubit>().printRouteStack();
                Navigator.of(context).push(
                  PageTransition(
                    child: const MyListFilms(),
                    type: PageTransitionType.rightToLeft,
                    duration: 300.ms,
                    reverseDuration: 300.ms,
                    settings: const RouteSettings(name: '/my_list_films'),
                  ),
                );
              },
            ),
            _ProfileSettingItem(
              title: 'Cài đặt ứng dụng',
              iconData: Icons.settings,
              onTap: () {},
            ),
            _ProfileSettingItem(
              title: 'Trợ giúp',
              iconData: Icons.help_center,
              onTap: () {},
            ),
            const SizedBox(
              height: 50,
            ),
            FilledButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc muốn tiếp tục?'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.white,
                    actions: [
                      TextButton(
                        onPressed: () async {
                          try {
                            await supabase.auth.signOut();
                          } catch (error) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Có lỗi xảy ra, đăng xuất thất bại')),
                              );
                            }
                          }
                        },
                        child: const Text('Có'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Huỷ'),
                      )
                    ],
                  ),
                );
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ĐĂNG XUẤT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ].animate(interval: 40.ms).fade().slideX(),
        ),
      ),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  void _updateUserInfo() {
    context.read<RouteStackCubit>().push('/update_user_info');
    Navigator.of(context)
        .push(
      PageTransition(
        child: const UpdateUserInfo(),
        type: PageTransitionType.rightToLeft,
        duration: 300.ms,
        reverseDuration: 300.ms,
        settings: const RouteSettings(name: '/update_user_info'),
      ),
    )
        .then(
      (hasChanged) {
        context.read<RouteStackCubit>().pop();
        // Nếu có nhấn nút "Cập nhật" thì khi quay lại trang Profile sẽ setState để update thông tin
        if (hasChanged == true) {
          setState(() {});
        }
      },
    );
  }

  void _deleteUser(BuildContext context) async {
    bool isProcessingDeleteUser = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setStateDialog) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xác nhận',
                  style: TextStyle(fontSize: 20),
                ),
                const Gap(14),
                SizedBox(
                  height: 50,
                  child: isProcessingDeleteUser
                      ? const Align(
                          child: SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        )
                      : const Text(
                          'Bạn có chắc muốn xoá vĩnh viễn tài khoản này không?',
                        ),
                ),
                const Gap(10),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: isProcessingDeleteUser
                          ? null
                          : () async {
                              setStateDialog(() {
                                isProcessingDeleteUser = true;
                              });

                              try {
                                // await supabase.rpc(
                                //   'delete_user',
                                //   params: {
                                //     'user_id': supabase.auth.currentUser!.id,
                                //   },
                                // );
                                await supabase.auth.admin
                                    .deleteUser(supabase.auth.currentUser!.id);

                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Hẹn gặp lại bạn.'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                await supabase.auth.signOut();
                              } on AuthException catch (error) {
                                print("error: ${error.message}");
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Có lỗi xảy ra, vui lòng thử lại')),
                                );
                              }

                              setStateDialog(() {
                                isProcessingDeleteUser = true;
                              });
                            },
                      child: const Text('Có'),
                    ),
                    TextButton(
                      onPressed: isProcessingDeleteUser
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text('Huỷ'),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: CachedNetworkImage(
                  imageUrl:
                      '$baseAvatarUrl${profileData['avatar_url']}?t=${DateTime.now()}',
                  fit: BoxFit.cover,
                  // fadeInDuration: là thời gian xuất hiện của Image khi đã load xong
                  fadeInDuration: const Duration(milliseconds: 400),
                  // fadeOutDuration: là thời gian biến mất của placeholder khi Image khi đã load xong
                  fadeOutDuration: const Duration(milliseconds: 800),
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(26),
                    child: CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(20),
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email: ${currentUser!.email!}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Tên: ${profileData['full_name']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Ngày sinh: ${profileData['dob']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            InkWell(
              onTap: _updateUserInfo,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withAlpha(50),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            InkWell(
              onTap: () => _deleteUser(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withAlpha(50),
                ),
                child: const Row(
                  children: [
                    Gap(12),
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Xoá tài khoản',
                      style: TextStyle(color: Colors.white),
                    ),
                    Gap(12),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(40),
      ],
    );
  }
}

class _ProfileSettingItem extends StatelessWidget {
  const _ProfileSettingItem({
    required this.title,
    required this.iconData,
    required this.onTap,
  });

  final String title;
  final IconData iconData;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withAlpha(50),
          ),
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.white,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
