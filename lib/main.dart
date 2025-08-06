import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Manrope',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Manrope'),
          displayMedium: TextStyle(fontFamily: 'Manrope'),
          displaySmall: TextStyle(fontFamily: 'Manrope'),
          headlineLarge: TextStyle(fontFamily: 'Manrope'),
          headlineMedium: TextStyle(fontFamily: 'Manrope'),
          headlineSmall: TextStyle(fontFamily: 'Manrope'),
          titleLarge: TextStyle(fontFamily: 'Manrope'),
          titleMedium: TextStyle(fontFamily: 'Manrope'),
          titleSmall: TextStyle(fontFamily: 'Manrope'),
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          bodySmall: TextStyle(fontFamily: 'Roboto'),
          labelLarge: TextStyle(fontFamily: 'Roboto'),
          labelMedium: TextStyle(fontFamily: 'Roboto'),
          labelSmall: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
