import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/produtos/view/lista_produtos_page.dart';
import 'firebase_options.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const ListaProdutosPage(),
    );
  }
}