
/// Representa um produto cadastrado no aplicativo.
class Produto {
  final String id;
  String clienteId;
  String nome;
  String unidade;
  double valor;
  String indice;

  Produto({
    required this.id,
    required this.clienteId,
    required this.nome,
    required this.unidade,
    required this.valor,
    required this.indice,
  });

  /// Converte o produto em um mapa para armazenamento JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'nome': nome,
      'unidade': unidade,
      'valor': valor,
      'indice': indice,
    };
  }

  /// Reconstrói um produto a partir dos dados armazenados.
  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id']?.toString() ?? '',
      clienteId: json['clienteId']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      unidade: json['unidade']?.toString() ?? 'Unidade',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      indice: json['indice']?.toString() ?? '',
    );
  }
}
