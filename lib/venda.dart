
/// Representa um item incluído em uma compra.
class ItemVenda {
  final String produtoId;
  final String nomeProduto;
  final String unidade;
  final int quantidade;
  final double valorUnitario;

  ItemVenda({
    required this.produtoId,
    required this.nomeProduto,
    required this.unidade,
    required this.quantidade,
    required this.valorUnitario,
  });

  /// Calcula o valor total deste item.
  double get subtotal => quantidade * valorUnitario;

  /// Converte o item para um mapa armazenável em JSON.
  Map<String, dynamic> toJson() {
    return {
      'produtoId': produtoId,
      'nomeProduto': nomeProduto,
      'unidade': unidade,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
    };
  }

  /// Reconstrói um item a partir dos dados armazenados.
  factory ItemVenda.fromJson(Map<String, dynamic> json) {
    return ItemVenda(
      produtoId: json['produtoId']?.toString() ?? '',
      nomeProduto: json['nomeProduto']?.toString() ?? '',
      unidade: json['unidade']?.toString() ?? 'Unidade',
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      valorUnitario:
          (json['valorUnitario'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Representa uma venda com um ou vários produtos.
class Venda {
  final String id;
  final String clienteId;
  final String nomeCliente;
  final String vendedor;
  final DateTime data;
  final List<ItemVenda> itens;

  Venda({
    required this.id,
    required this.clienteId,
    required this.nomeCliente,
    required this.vendedor,
    required this.data,
    required this.itens,
  });

  /// Soma os subtotais de todos os itens da venda.
  double get total {
    return itens.fold(
      0.0,
      (soma, item) => soma + item.subtotal,
    );
  }

  /// Converte a venda completa para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'nomeCliente': nomeCliente,
      'vendedor': vendedor,
      'data': data.toIso8601String(),
      'itens': itens.map((item) => item.toJson()).toList(),
    };
  }

  /// Reconstrói uma venda a partir dos dados armazenados.
  factory Venda.fromJson(Map<String, dynamic> json) {
    final listaItens = (json['itens'] as List? ?? []);

    return Venda(
      id: json['id']?.toString() ?? '',
      clienteId: json['clienteId']?.toString() ?? '',
      nomeCliente: json['nomeCliente']?.toString() ?? '',
      vendedor: json['vendedor']?.toString() ?? '',
      data: DateTime.tryParse(
            json['data']?.toString() ?? '',
          ) ??
          DateTime.now(),
      itens: listaItens
          .map(
            (item) => ItemVenda.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}
