import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/assistant_state.dart';
import 'package:homepod_assistant/providers/app_config.dart';
import 'package:homepod_assistant/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for the round display
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const HomePodApp());
}

class HomePodApp extends StatelessWidget {
  const HomePodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssistantState()),
        ChangeNotifierProvider(create: (_) => AppConfig()),
      ],
      child: MaterialApp(
        title: 'HomePod Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E1E1E),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF000000),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w300,
            ),
            displayMedium: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
            bodyLarge: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            bodyMedium: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
