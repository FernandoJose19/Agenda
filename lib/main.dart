
import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  // Inicializa o aplicativo Flutter.
  runApp(const AplicativoCompras());
}

class AplicativoCompras extends StatelessWidget {
  const AplicativoCompras({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nome do aplicativo.
      title: 'Cadastro e Compras',

      // Remove a faixa de depuração.
      debugShowCheckedModeBanner: false,

      // Configura o tema visual do aplicativo.
      theme: ThemeData(
        useMaterial3: true,

        // Define a cor principal.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2868D7),
        ),

        // Define a cor de fundo das telas.
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),

        // Configuração dos cartões.
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
        ),

        // Configuração dos campos de entrada.
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),

      // Define a tela inicial do aplicativo.
      home: const Home(),
    );
  }
}
