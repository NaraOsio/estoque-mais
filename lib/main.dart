import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/autenticacao/view/login_page.dart';
import 'firebase_options.dart';

const _verdePrincipal = Color(0xFF1B5E20);
const _fundoClaro = Color(0xFFF7FAF7);
const _cinzaBorda = Color(0xFFD7E1D7);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EstoqueMaisApp());
}

class EstoqueMaisApp extends StatelessWidget {
  const EstoqueMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estoque+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _fundoClaro,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _verdePrincipal,
          primary: _verdePrincipal,
          secondary: _verdePrincipal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _verdePrincipal,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cinzaBorda),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cinzaBorda),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _verdePrincipal,
              width: 2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _verdePrincipal,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}