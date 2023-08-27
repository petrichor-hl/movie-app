import 'package:flutter/material.dart';

import 'package:movie_app/screens/export_screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://kpaxjjmelbqpllxenpxz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwYXhqam1lbGJxcGxseGVucHh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMwNDY0OTQsImV4cCI6MjAwODYyMjQ5NH0.MRzIQjr-s1pvy_PL_SM-ahW71ry63H5aNLRUSjMYFiw',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 229, 9, 21),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
