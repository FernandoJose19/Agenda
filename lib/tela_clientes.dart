import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'armazenamento_local.dart';
import 'cliente.dart';
import 'formatadores.dart';

/// Tela de cadastro e gerenciamento de clientes.
class TelaClientes extends StatefulWidget {
  const TelaClientes({super.key});

  @override
  State<TelaClientes> createState() => _TelaClientesState();
}

class _TelaClientesState extends State<TelaClientes> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _turmaController = TextEditingController();
  final _indiceController = TextEditingController();

  List<Cliente> _clientes = [];
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _apelidoController.dispose();
    _turmaController.dispose();
    _indiceController.dispose();
    super.dispose();
  }

  /// Carrega os clientes salvos no dispositivo.
  Future<void> _carregarClientes() async {
    final clientes = await ArmazenamentoLocal.carregarClientes();

    if (!mounted) return;

    setState(() {
      _clientes = clientes;
      _carregando = false;
    });
  }

  /// Limpa os campos do formulário.
  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _cpfController.clear();
    _telefoneController.clear();
    _apelidoController.clear();
    _turmaController.clear();
    _indiceController.clear();
  }

  /// Salva um novo cliente ou atualiza um existente.
  Future<void> _salvarCliente({Cliente? clienteExistente}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final cliente = Cliente(
      id: clienteExistente?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nome: _nomeController.text.trim(),
      cpf: _cpfController.text.trim(),
      telefone: _telefoneController.text.trim(),
      apelido: _apelidoController.text.trim(),
      turmaTurno: _turmaController.text.trim(),
      indice: _indiceController.text.trim(),
    );

    final clientesAtualizados = [..._clientes];

    if (clienteExistente == null) {
      clientesAtualizados.add(cliente);
    } else {
      final posicao = clientesAtualizados.indexWhere(
        (item) => item.id == clienteExistente.id,
      );

      if (posicao != -1) {
        clientesAtualizados[posicao] = cliente;
      }
    }

    try {
      await ArmazenamentoLocal.salvarClientes(clientesAtualizados);

      if (!mounted) return;

      setState(() {
        _clientes = clientesAtualizados;
        _salvando = false;
      });

      _limparFormulario();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            clienteExistente == null
                ? 'Cliente cadastrado com sucesso!'
                : 'Cliente atualizado com sucesso!',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o cliente.'),
        ),
      );
    }
  }

  /// Preenche o formulário com os dados para edição.
  void _editarCliente(Cliente cliente) {
    _nomeController.text = cliente.nome;
    _cpfController.text = cliente.cpf;
    _telefoneController.text = cliente.telefone;
    _apelidoController.text = cliente.apelido;
    _turmaController.text = cliente.turmaTurno;
    _indiceController.text = cliente.indice;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Altere os campos e pressione Salvar alterações.',
        ),
      ),
    );

    setState(() {});
  }

  /// Confirma antes de excluir um cliente.
  Future<void> _excluirCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text(
          'Deseja excluir o cliente "${cliente.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final clientesAtualizados = _clientes
        .where((item) => item.id != cliente.id)
        .toList();

    await ArmazenamentoLocal.salvarClientes(clientesAtualizados);

    if (!mounted) return;

    setState(() => _clientes = clientesAtualizados);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente excluído.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Clientes'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Dados do cliente',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          const SizedBox(height: 16),

                          _campo(
                            controller: _nomeController,
                            label: 'Nome completo',
                            icone: Icons.person_outline,
                            obrigatorio: true,
                          ),
                          const SizedBox(height: 12),

                          _campo(
                            controller: _cpfController,
                            label: 'CPF',
                            icone: Icons.badge_outlined,
                            teclado: TextInputType.number,
                            formatadores: [CpfFormatter()],
                          ),
                          const SizedBox(height: 12),

                          _campo(
                            controller: _telefoneController,
                            label: 'Telefone',
                            icone: Icons.phone_outlined,
                            teclado: TextInputType.phone,
                            formatadores: [TelefoneFormatter()],
                          ),
                          const SizedBox(height: 12),

                          _campo(
                            controller: _apelidoController,
                            label: 'Apelido',
                            icone: Icons.tag,
                          ),
                          const SizedBox(height: 12),

                          _campo(
                            controller: _turmaController,
                            label: 'Turma / Turno',
                            icone: Icons.groups_outlined,
                          ),
                          const SizedBox(height: 12),

                          _campo(
                            controller: _indiceController,
                            label: 'Índice',
                            icone: Icons.numbers,
                          ),
                          const SizedBox(height: 20),

                          FilledButton.icon(
                            onPressed: _salvando
                                ? null
                                : () => _salvarCliente(),
                            icon: Icon(
                              _salvando
                                  ? Icons.hourglass_top
                                  : Icons.save_outlined,
                            ),
                            label: const Text('Cadastrar cliente'),
                          ),

                          TextButton(
                            onPressed: _salvando
                                ? null
                                : _limparFormulario,
                            child: const Text('Limpar campos'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Clientes cadastrados (${_clientes.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                if (_carregando)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_clientes.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum cliente cadastrado.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ..._clientes.map(
                    (cliente) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(cliente.nome),
                        subtitle: Text(
                          [
                            if (cliente.cpf.isNotEmpty)
                              'CPF: ${cliente.cpf}',
                            if (cliente.telefone.isNotEmpty)
                              'Telefone: ${cliente.telefone}',
                            if (cliente.apelido.isNotEmpty)
                              'Apelido: ${cliente.apelido}',
                            if (cliente.turmaTurno.isNotEmpty)
                              'Turma / Turno: ${cliente.turmaTurno}',
                            if (cliente.indice.isNotEmpty)
                              'Índice: ${cliente.indice}',
                          ].join('\n'),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Ações do cliente',
                          onSelected: (acao) {
                            if (acao == 'editar') {
                              _editarCliente(cliente);
                            } else if (acao == 'excluir') {
                              _excluirCliente(cliente);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói campos padronizados para o formulário.
  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    bool obrigatorio = false,
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter> formatadores = const [],
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      inputFormatters: formatadores,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: const OutlineInputBorder(),
      ),
      validator: obrigatorio
          ? (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Informe $label.';
              }
              return null;
            }
          : null,
    );
  }
}
