
import 'package:flutter/material.dart';

import 'armazenamento_local.dart';
import 'cliente.dart';
import 'formatadores.dart';
import 'produto.dart';
import 'venda.dart';

/// Tela para montar uma compra com vários produtos.
class TelaVendas extends StatefulWidget {
  const TelaVendas({super.key});

  @override
  State<TelaVendas> createState() => _TelaVendasState();
}

class _TelaVendasState extends State<TelaVendas> {
  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];
  List<Venda> _vendas = [];
  List<ItemVenda> _itens = [];

  String? _clienteSelecionado;
  String? _produtoSelecionado;

  final _vendedorController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');

  DateTime _dataVenda = DateTime.now();
  bool _carregando = true;
  bool _salvando = false;

  /// Produtos disponíveis para o cliente selecionado.
  List<Produto> get _produtosDisponiveis {
    if (_clienteSelecionado == null) return [];

    return _produtos
        .where((produto) =>
            produto.clienteId == _clienteSelecionado)
        .toList();
  }

  /// Soma os valores de todos os itens da compra.
  double get _total {
    return _itens.fold(
      0.0,
      (soma, item) => soma + item.subtotal,
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  /// Carrega os cadastros, vendas e possível rascunho.
  Future<void> _carregarDados() async {
    try {
      final clientes = await ArmazenamentoLocal.carregarClientes();
      final produtos = await ArmazenamentoLocal.carregarProdutos();
      final vendas = await ArmazenamentoLocal.carregarVendas();
      final rascunho = await ArmazenamentoLocal.carregarRascunho();

      String? clienteId;
      String vendedor = '';
      DateTime data = DateTime.now();
      List<ItemVenda> itens = [];

      if (rascunho != null) {
        clienteId = rascunho['clienteId'] as String?;
        vendedor = rascunho['vendedor'] as String? ?? '';

        data = DateTime.tryParse(
              rascunho['data'] as String? ?? '',
            ) ??
            DateTime.now();

        itens = (rascunho['itens'] as List? ?? [])
            .map(
              (item) => ItemVenda.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      // Evita selecionar um cliente que não existe mais.
      if (clienteId != null &&
          !clientes.any((cliente) => cliente.id == clienteId)) {
        clienteId = null;
        itens = [];
      }

      // Mantém apenas produtos pertencentes ao cliente selecionado.
      itens = itens.where((item) {
        return produtos.any(
          (produto) =>
              produto.id == item.produtoId &&
              produto.clienteId == clienteId,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _clientes = clientes;
        _produtos = produtos;
        _vendas = vendas;
        _clienteSelecionado = clienteId;
        _vendedorController.text = vendedor;
        _dataVenda = data;
        _itens = itens;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _carregando = false);
      _mensagem('Não foi possível carregar os dados.');
    }
  }

  /// Salva a compra ainda não concluída.
  Future<void> _salvarRascunho() async {
    await ArmazenamentoLocal.salvarRascunho({
      'clienteId': _clienteSelecionado,
      'vendedor': _vendedorController.text.trim(),
      'data': _dataVenda.toIso8601String(),
      'itens': _itens.map((item) => item.toJson()).toList(),
    });
  }

  /// Adiciona o produto selecionado à compra.
  Future<void> _adicionarProduto() async {
    if (_clienteSelecionado == null) {
      _mensagem('Selecione um cliente primeiro.');
      return;
    }

    if (_produtoSelecionado == null) {
      _mensagem('Selecione um produto.');
      return;
    }

    final quantidade = int.tryParse(
      _quantidadeController.text.trim(),
    );

    if (quantidade == null || quantidade <= 0) {
      _mensagem('Informe uma quantidade inteira maior que zero.');
      return;
    }

    final produto = _produtos.firstWhere(
      (item) =>
          item.id == _produtoSelecionado &&
          item.clienteId == _clienteSelecionado,
    );

    // Se o produto já estiver na compra, soma as quantidades.
    final indice = _itens.indexWhere(
      (item) => item.produtoId == produto.id,
    );

    setState(() {
      if (indice >= 0) {
        final anterior = _itens[indice];

        _itens[indice] = ItemVenda(
          produtoId: anterior.produtoId,
          nomeProduto: anterior.nomeProduto,
          unidade: anterior.unidade,
          quantidade: anterior.quantidade + quantidade,
          valorUnitario: anterior.valorUnitario,
        );
      } else {
        _itens.add(
          ItemVenda(
            produtoId: produto.id,
            nomeProduto: produto.nome,
            unidade: produto.unidade,
            quantidade: quantidade,
            valorUnitario: produto.valor,
          ),
        );
      }
    });

    _quantidadeController.text = '1';

    await _salvarRascunho();

    if (!mounted) return;
    _mensagem('Produto adicionado à compra.');
  }

  /// Remove um item da compra.
  Future<void> _removerItem(int indice) async {
    setState(() {
      _itens.removeAt(indice);
    });

    await _salvarRascunho();
  }

  /// Abre o calendário para escolher a data.
  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataVenda,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data == null) return;

    setState(() => _dataVenda = data);
    await _salvarRascunho();
  }

  /// Limpa a compra após confirmação.
  Future<void> _limparCompra() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar compra'),
        content: const Text(
          'Deseja remover todos os itens desta compra?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _clienteSelecionado = null;
      _produtoSelecionado = null;
      _itens.clear();
      _vendedorController.clear();
      _quantidadeController.text = '1';
      _dataVenda = DateTime.now();
    });

    await ArmazenamentoLocal.excluirRascunho();

    if (!mounted) return;
    _mensagem('Lista limpa.');
  }

  /// Registra a compra completa no armazenamento local.
  Future<void> _concluirCompra() async {
    if (_clienteSelecionado == null) {
      _mensagem('Selecione um cliente.');
      return;
    }

    if (_itens.isEmpty) {
      _mensagem('Adicione pelo menos um produto.');
      return;
    }

    if (_vendedorController.text.trim().isEmpty) {
      _mensagem('Informe o vendedor.');
      return;
    }

    final cliente = _clientes.firstWhere(
      (item) => item.id == _clienteSelecionado,
    );

    final venda = Venda(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      clienteId: cliente.id,
      nomeCliente: cliente.nome,
      vendedor: _vendedorController.text.trim(),
      data: _dataVenda,
      itens: List<ItemVenda>.from(_itens),
    );

    setState(() => _salvando = true);

    try {
      final novasVendas = [..._vendas, venda];

      await ArmazenamentoLocal.salvarVendas(novasVendas);
      await ArmazenamentoLocal.excluirRascunho();

      if (!mounted) return;

      setState(() {
        _vendas = novasVendas;
        _clienteSelecionado = null;
        _produtoSelecionado = null;
        _itens = [];
        _vendedorController.clear();
        _quantidadeController.text = '1';
        _dataVenda = DateTime.now();
        _salvando = false;
      });

      _mensagem(
        'Compra concluída! Total: ${_moeda(venda.total)}',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _salvando = false);
      _mensagem('Não foi possível concluir a compra.');
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  String _moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  @override
  void dispose() {
    _vendedorController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar compra'),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Cadastre um cliente antes de registrar uma compra.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final largo = constraints.maxWidth >= 850;

                    final formulario = _construirFormulario();
                    final lista = _construirLista();
                    final resumo = _construirResumo();

                    if (largo) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  formulario,
                                  const SizedBox(height: 20),
                                  lista,
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: resumo,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        formulario,
                        const SizedBox(height: 16),
                        lista,
                        const SizedBox(height: 16),
                        resumo,
                      ],
                    );
                  },
                ),
    );
  }

  /// Formulário para escolher cliente, data e produtos.
  Widget _construirFormulario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dados da compra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _clienteSelecionado,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              items: _clientes.map((cliente) {
                return DropdownMenuItem<String>(
                  value: cliente.id,
                  child: Text(
                    cliente.nome,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (valor) async {
                setState(() {
                  _clienteSelecionado = valor;
                  _produtoSelecionado = null;
                  _itens.clear();
                });

                await _salvarRascunho();
              },
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _selecionarData,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data da compra',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(_formatarData(_dataVenda)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _vendedorController,
              decoration: const InputDecoration(
                labelText: 'Vendedor',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _salvarRascunho(),
            ),
            const SizedBox(height: 20),

            Text(
              'Adicionar produtos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _produtoSelecionado,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Produto',
                border: OutlineInputBorder(),
              ),
              items: _produtosDisponiveis.map((produto) {
                return DropdownMenuItem<String>(
                  value: produto.id,
                  child: Text(
                    '${produto.nome} — ${_moeda(produto.valor)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() => _produtoSelecionado = valor);
              },
            ),

            if (_clienteSelecionado != null &&
                _produtosDisponiveis.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Este cliente não possui produtos cadastrados.',
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LimiteNumericoFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _salvando ? null : _adicionarProduto,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Lista todos os produtos incluídos na compra.
  Widget _construirLista() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Produtos desta compra (${_itens.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            if (_itens.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Nenhum produto adicionado.',
                  textAlign: TextAlign.center,
                ),
              ),

            ..._itens.asMap().entries.map((entrada) {
              final indice = entrada.key;
              final item = entrada.value;

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.nomeProduto),
                    subtitle: Text(
                      '${item.quantidade} ${item.unidade} × '
                      '${_moeda(item.valorUnitario)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _moeda(item.subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remover produto',
                          onPressed: _salvando
                              ? null
                              : () => _removerItem(indice),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            }),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total parcial'),
                Text(
                  _moeda(_total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Exibe o resumo e as ações finais.
  Widget _construirResumo() {
    final clienteSelecionado = _clientes
        .where((cliente) => cliente.id == _clienteSelecionado)
        .map((cliente) => cliente.nome)
        .firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumo da compra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            const Text('Data'),
            Text(
              _formatarData(_dataVenda),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            const Text('Cliente'),
            Text(
              clienteSelecionado ?? 'Não selecionado',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            const Text('Vendedor'),
            Text(
              _vendedorController.text.trim().isEmpty
                  ? 'Não informado'
                  : _vendedorController.text.trim(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            const Divider(),

            const Text('Total da compra'),
            const SizedBox(height: 4),
            Text(
              _moeda(_total),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _salvando ? null : _limparCompra,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Limpar lista'),
            ),
            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: _salvando ? null : _concluirCompra,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                _salvando ? 'Salvando...' : 'Concluir compra',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
