import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/onboarding/onboarding.dart';
import 'package:movie_app/screens/my_list_films.dart';
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
  late final Future<void> _futureUserInfo;

  void _clearGlobalDataOfUser() {
    profileData.clear();
    offlineMovies.clear();
    offlineTvs.clear();
    downloadedEpisodeId.clear();
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session == null) {
        _clearGlobalDataOfUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => const OnboardingScreen()),
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
            const SizedBox(
              height: 70,
            ),
            _ProfileSettingItem(
              title: 'Danh sách',
              iconData: Icons.list,
              onTap: () {
                context.read<RouteStackCubit>().push('/my_list_films');
                Navigator.of(context)
                    .push(
                      PageTransition(
                        child: const MyListFilms(),
                        type: PageTransitionType.rightToLeft,
                        duration: 300.ms,
                        reverseDuration: 300.ms,
                        settings: const RouteSettings(name: '/my_list_films'),
                      ),
                    )
                    .then((_) => context.read<RouteStackCubit>().pop());
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

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          'Email: ${currentUser!.email!}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        Text(
          'Tên: ${profileData['full_name']}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        Text(
          'Ngày sinh: ${profileData['dob']}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withAlpha(27),
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
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withAlpha(27),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
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
            color: Colors.white.withAlpha(27),
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
