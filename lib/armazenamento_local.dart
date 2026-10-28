
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cliente.dart';
import 'produto.dart';
import 'venda.dart';

/// Centraliza o armazenamento local dos dados do aplicativo.
class ArmazenamentoLocal {
  static const String _chaveClientes = 'cadastro_compras_clientes';
  static const String _chaveProdutos = 'cadastro_compras_produtos';
  static const String _chaveVendas = 'cadastro_compras_vendas';
  static const String _chaveRascunho = 'cadastro_compras_rascunho';

  /// Salva a lista de clientes.
  static Future<void> salvarClientes(List<Cliente> clientes) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = clientes.map((cliente) => cliente.toJson()).toList();

    await prefs.setString(_chaveClientes, jsonEncode(dados));
  }

  /// Recupera os clientes salvos.
  static Future<List<Cliente>> carregarClientes() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(_chaveClientes);

    if (texto == null || texto.isEmpty) {
      return [];
    }

    try {
      final dados = jsonDecode(texto) as List;

      return dados
          .map(
            (item) => Cliente.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Salva a lista de produtos.
  static Future<void> salvarProdutos(List<Produto> produtos) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = produtos.map((produto) => produto.toJson()).toList();

    await prefs.setString(_chaveProdutos, jsonEncode(dados));
  }

  /// Recupera os produtos salvos.
  static Future<List<Produto>> carregarProdutos() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(_chaveProdutos);

    if (texto == null || texto.isEmpty) {
      return [];
    }

    try {
      final dados = jsonDecode(texto) as List;

      return dados
          .map(
            (item) => Produto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Salva o histórico de vendas.
  static Future<void> salvarVendas(List<Venda> vendas) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = vendas.map((venda) => venda.toJson()).toList();

    await prefs.setString(_chaveVendas, jsonEncode(dados));
  }

  /// Recupera o histórico de vendas.
  static Future<List<Venda>> carregarVendas() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(_chaveVendas);

    if (texto == null || texto.isEmpty) {
      return [];
    }

    try {
      final dados = jsonDecode(texto) as List;

      return dados
          .map(
            (item) => Venda.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Salva um rascunho de compra ainda não concluída.
  static Future<void> salvarRascunho(
    Map<String, dynamic> rascunho,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _chaveRascunho,
      jsonEncode(rascunho),
    );
  }

  /// Recupera o rascunho da compra, se existir.
  static Future<Map<String, dynamic>?> carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(_chaveRascunho);

    if (texto == null || texto.isEmpty) {
      return null;
    }

    try {
      final dados = jsonDecode(texto);

      if (dados is Map) {
        return Map<String, dynamic>.from(dados);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Apaga o rascunho depois que a compra for concluída.
  static Future<void> excluirRascunho() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_chaveRascunho);
  }
}
