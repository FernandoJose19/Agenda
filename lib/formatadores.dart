
import 'package:flutter/services.dart';

/// Permite somente números e limita a quantidade de dígitos.
class LimiteNumericoFormatter extends TextInputFormatter {
  final int limite;

  LimiteNumericoFormatter(this.limite);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numeros = newValue.text.replaceAll(RegExp(r'\D'), '');

    final limitados = numeros.length > limite
        ? numeros.substring(0, limite)
        : numeros;

    return TextEditingValue(
      text: limitados,
      selection: TextSelection.collapsed(
        offset: limitados.length,
      ),
    );
  }
}

/// Formata CPF como 000.000.000-00, limitado a 11 dígitos.
class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numeros = newValue.text.replaceAll(RegExp(r'\D'), '');

    final cpf = numeros.length > 11
        ? numeros.substring(0, 11)
        : numeros;

    final buffer = StringBuffer();

    for (var i = 0; i < cpf.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');

      buffer.write(cpf[i]);
    }

    final texto = buffer.toString();

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(
        offset: texto.length,
      ),
    );
  }
}

/// Formata telefone brasileiro.
class TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numeros = newValue.text.replaceAll(RegExp(r'\D'), '');

    final telefone = numeros.length > 11
        ? numeros.substring(0, 11)
        : numeros;

    if (telefone.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final buffer = StringBuffer('(');

    final dddLength =
        telefone.length < 2 ? telefone.length : 2;

    buffer.write(telefone.substring(0, dddLength));

    if (telefone.length >= 2) {
      buffer.write(') ');

      final restante = telefone.substring(2);

      final tamanhoParte = telefone.length == 11 ? 5 : 4;

      final parte = restante.length > tamanhoParte
          ? restante.substring(0, tamanhoParte)
          : restante;

      buffer.write(parte);

      if (restante.length > tamanhoParte) {
        buffer.write('-');
        buffer.write(restante.substring(tamanhoParte));
      }
    }

    final texto = buffer.toString();

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(
        offset: texto.length,
      ),
    );
  }
}

/// Formata valores monetários brasileiros, como R$ 1.234,56.
///
/// Os dígitos digitados são interpretados como centavos.
class ValorMonetarioFormatter extends TextInputFormatter {
  final int maxDigitos;

  ValorMonetarioFormatter({this.maxDigitos = 12});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    var numeros = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (numeros.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (numeros.length > maxDigitos) {
      numeros = numeros.substring(0, maxDigitos);
    }

    final centavos = int.tryParse(numeros) ?? 0;

    final valor = (centavos / 100).toStringAsFixed(2);

    final partes = valor.split('.');

    final inteiro = partes[0];
    final decimal = partes[1];

    final formatado = inteiro.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    final texto = 'R\$ $formatado,$decimal';

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(
        offset: texto.length,
      ),
    );
  }
}
