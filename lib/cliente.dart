
/// Representa um cliente cadastrado no aplicativo.
class Cliente {
  final String id;

  String nome;
  String cpf;
  String telefone;
  String apelido;
  String turmaTurno;
  String indice;

  Cliente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.apelido,
    required this.turmaTurno,
    required this.indice,
  });

  /// Converte os dados do cliente em um mapa
  /// para permitir o armazenamento em JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'apelido': apelido,
      'turmaTurno': turmaTurno,
      'indice': indice,
    };
  }

  /// Reconstrói um cliente a partir dos dados salvos.
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      apelido: json['apelido'] ?? '',
      turmaTurno: json['turmaTurno'] ?? '',
      indice: json['indice'] ?? '',
    );
  }
}
