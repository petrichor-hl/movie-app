import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/appbar/app_bar_cubit.dart';
import 'package:movie_app/screens/main/downloaded.dart';
import 'package:movie_app/screens/main/home.dart';
import 'package:movie_app/screens/main/new_hot.dart';
import 'package:movie_app/screens/main/profile.dart';

const Map<String, IconData> _icons = {
  'Trang chủ': Icons.home_rounded,
  'Mới & Hot': Icons.video_stable_rounded,
  'Tải xuống': Icons.download_rounded,
  'Hồ sơ': Icons.account_box,
};

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List<Widget> _screens = const [
    HomeScreen(
      key: PageStorageKey('homeScreen'),
    ),
    NewHotScreen(
      key: PageStorageKey('newhotScreen'),
    ),
    DownloadedScreen(),
    ProfileScreen(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: BlocProvider(
      //   create: (ctx) => AppBarCubit(),
      //   child: _screens[_currentIndex],
      // ),
      body: BlocProvider(
        create: (ctx) => AppBarCubit(),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _icons.entries
            .map(
              (e) => BottomNavigationBarItem(
                icon: Icon(
                  e.value,
                  size: 28,
                ),
                label: e.key,
              ),
            )
            .toList(),
        onTap: (value) => setState(() {
          _currentIndex = value;
        }),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
      ),
    );
  }
}
