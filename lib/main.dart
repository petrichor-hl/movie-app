import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:movie_app/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Supabase.initialize(
    url: '',
    anonKey: '',
    authOptions: const FlutterAuthClientOptions(
      // authFlowType: AuthFlowType.pkce,
      authFlowType: AuthFlowType.implicit,
    ),
    /*
    If you use PKCE (default), this link only works on the device or browser where the original reset request was made. Display a message to the user to make sure they don't change devices or browsers.
    If you used PKCE (default), the redirect contains the code query param.
    If you use the implicit grant flow, the link can be opened on any device.
    If you used the implicit flow, the redirect contains a URL fragment encoding the user's session.
    
    More: https://supabase.com/docs/guides/auth/passwords
    */
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MyListCubit(),
        ),
        BlocProvider(
          create: (context) => RouteStackCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
const tmdbApiKey = '';
const baseAvatarUrl = '';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
      ],
      locale: const Locale('vi'),
    );
  }
}
