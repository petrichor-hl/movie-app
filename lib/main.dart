import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:movie_app/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Supabase.initialize(
    url: 'https://kpaxjjmelbqpllxenpxz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwYXhqam1lbGJxcGxseGVucHh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMwNDY0OTQsImV4cCI6MjAwODYyMjQ5NH0.MRzIQjr-s1pvy_PL_SM-ahW71ry63H5aNLRUSjMYFiw',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => MyListCubit(),
      ),
      BlocProvider(
        create: (context) => RouteStackCubit(),
      ),
    ],
    child: const MyApp(),
  ));
}

final supabase = Supabase.instance.client;
const tmdbApiKey = 'a29284b32c092cc59805c9f5513d3811';

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
        textTheme: GoogleFonts.montserratTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
