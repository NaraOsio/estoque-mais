import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/autenticacao/view/login_page.dart';
import 'firebase_options.dart';

const _verdePrincipal = Color(0xFF1B5E20);
const _laranjaDestaque = Color(0xFFF57C00);
const _fundoClaro = Color(0xFFF7FAF7);
const _cinzaBorda = Color(0xFFD7E1D7);
const _textoPrincipal = Color(0xFF1F3323);
const _textoSecundario = Color(0xFF617265);

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
          secondary: _laranjaDestaque,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: _textoPrincipal,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(
            color: _textoPrincipal,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: _textoPrincipal,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: _textoPrincipal,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: _textoSecundario,
            fontSize: 14,
            height: 1.35,
          ),
          labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _verdePrincipal,
          size: 22,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _verdePrincipal,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          toolbarHeight: 64,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 24,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.white,
            size: 24,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: const TextStyle(
            color: _textoSecundario,
            fontSize: 14,
          ),
          prefixIconColor: _verdePrincipal,
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
            padding: const EdgeInsets.symmetric(vertical: 17),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _laranjaDestaque,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: _verdePrincipal,
          titleTextStyle: TextStyle(
            color: _textoPrincipal,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}