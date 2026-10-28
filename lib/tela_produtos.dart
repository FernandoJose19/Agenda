
import 'package:flutter/material.dart';

import 'armazenamento_local.dart';
import 'cliente.dart';
import 'formatadores.dart';
import 'produto.dart';

/// Tela para cadastrar produtos e associá-los a um cliente.
class TelaProdutos extends StatefulWidget {
  const TelaProdutos({super.key});

  @override
  State<TelaProdutos> createState() => _TelaProdutosState();
}

class _TelaProdutosState extends State<TelaProdutos> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _indiceController = TextEditingController();

  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];

  String? _clienteSelecionado;
  String _unidade = 'Unidade';
  String? _produtoEmEdicao;
  bool _carregando = true;
  bool _salvando = false;

  final List<String> _unidades = [
    'Unidade',
    'Pacote',
    'Caixa',
    'Quilo',
    'Grama',
    'Litro',
    'Metro',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _indiceController.dispose();
    super.dispose();
  }

  /// Carrega clientes e produtos já salvos.
  Future<void> _carregarDados() async {
    final clientes = await ArmazenamentoLocal.carregarClientes();
    final produtos = await ArmazenamentoLocal.carregarProdutos();

    if (!mounted) return;

    setState(() {
      _clientes = clientes;
      _produtos = produtos;
      _carregando = false;
    });
  }

  /// Salva um novo produto ou atualiza um existente.
  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente.'),
        ),
      );
      return;
    }

    final valorTexto = _valorController.text
        .trim()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final valor = double.tryParse(valorTexto);

    if (valor == null || valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor válido.'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final produto = Produto(
      id: _produtoEmEdicao ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      clienteId: _clienteSelecionado!,
      nome: _nomeController.text.trim(),
      unidade: _unidade,
      valor: valor,
      indice: _indiceController.text.trim(),
    );

    final produtosAtualizados = [..._produtos];

    if (_produtoEmEdicao == null) {
      produtosAtualizados.add(produto);
    } else {
      final posicao = produtosAtualizados.indexWhere(
        (item) => item.id == _produtoEmEdicao,
      );

      if (posicao != -1) {
        produtosAtualizados[posicao] = produto;
      }
    }

    try {
      await ArmazenamentoLocal.salvarProdutos(produtosAtualizados);

      if (!mounted) return;

      setState(() {
        _produtos = produtosAtualizados;
        _salvando = false;
      });

      _limparFormulario();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _produtoEmEdicao == null
                ? 'Produto cadastrado com sucesso!'
                : 'Produto atualizado com sucesso!',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o produto.'),
        ),
      );
    }
  }

  /// Limpa o formulário.
  void _limparFormulario() {
    _nomeController.clear();
    _valorController.clear();
    _indiceController.clear();

    setState(() {
      _produtoEmEdicao = null;
      _clienteSelecionado = null;
      _unidade = 'Unidade';
    });
  }

  /// Prepara o formulário para editar um produto.
void _editarProduto(Produto produto) {
  setState(() {
    _produtoEmEdicao = produto.id;
    _clienteSelecionado = produto.clienteId;
    _unidade = produto.unidade;
    _nomeController.text = produto.nome;

    // Converte o valor para centavos, como o formatador espera.
    final centavos = (produto.valor * 100).round();
    final digitos = centavos.toString().padLeft(3, '0');

    final parteInteira = digitos
        .substring(0, digitos.length - 2);
    final centavosTexto = digitos.substring(digitos.length - 2);

    _valorController.text =
        'R\$ $parteInteira,$centavosTexto';

    _indiceController.text = produto.indice;
  });
}

  /// Exclui um produto após confirmação.
  Future<void> _excluirProduto(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text(
          'Deseja excluir o produto "${produto.nome}"?',
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

    final produtosAtualizados = _produtos
        .where((item) => item.id != produto.id)
        .toList();

    await ArmazenamentoLocal.salvarProdutos(produtosAtualizados);

    if (!mounted) return;

    setState(() => _produtos = produtosAtualizados);

    if (_produtoEmEdicao == produto.id) {
      _limparFormulario();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto excluído.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtosVisiveis = _clienteSelecionado == null
        ? _produtos
        : _produtos
            .where((produto) =>
                produto.clienteId == _clienteSelecionado)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produtos'),
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
                            _produtoEmEdicao == null
                                ? 'Dados do produto'
                                : 'Editar produto',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _clienteSelecionado,
                            decoration: const InputDecoration(
                              labelText: 'Cliente',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            items: _clientes.map((cliente) {
                              return DropdownMenuItem<String>(
                                value: cliente.id,
                                child: Text(cliente.nome),
                              );
                            }).toList(),
                            onChanged: (valor) {
                              setState(() {
                                _clienteSelecionado = valor;
                              });
                            },
                            validator: (valor) {
                              if (valor == null) {
                                return 'Selecione um cliente.';
                              }
                              return null;
                            },
                          ),
                          if (_clientes.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Cadastre um cliente antes de cadastrar produtos.',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _nomeController,
                            decoration: const InputDecoration(
                              labelText: 'Nome do produto',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              if (valor == null ||
                                  valor.trim().isEmpty) {
                                return 'Informe o nome do produto.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: _unidade,
                            decoration: const InputDecoration(
                              labelText: 'Unidade de medida',
                              prefixIcon: Icon(Icons.straighten),
                              border: OutlineInputBorder(),
                            ),
                            items: _unidades.map((unidade) {
                              return DropdownMenuItem<String>(
                                value: unidade,
                                child: Text(unidade),
                              );
                            }).toList(),
                            onChanged: (valor) {
                              if (valor == null) return;
                              setState(() => _unidade = valor);
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _valorController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              ValorMonetarioFormatter(),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Valor unitário',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                              hintText: 'R\$ 0,00',
                            ),
                            validator: (valor) {
                              if (valor == null ||
                                  valor.trim().isEmpty) {
                                return 'Informe o valor do produto.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _indiceController,
                            decoration: const InputDecoration(
                              labelText: 'Índice',
                              prefixIcon: Icon(Icons.numbers),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          FilledButton.icon(
                            onPressed: _salvando || _clientes.isEmpty
                                ? null
                                : _salvarProduto,
                            icon: Icon(
                              _salvando
                                  ? Icons.hourglass_top
                                  : Icons.save_outlined,
                            ),
                            label: Text(
                              _produtoEmEdicao == null
                                  ? 'Cadastrar produto'
                                  : 'Salvar alterações',
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _salvando ? null : _limparFormulario,
                            child: const Text('Limpar campos'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Produtos cadastrados (${produtosVisiveis.length})',
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
                else if (_produtos.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum produto cadastrado.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...produtosVisiveis.map((produto) {
                    final cliente = _clientes
                        .where((item) => item.id == produto.clienteId)
                        .firstOrNull;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.inventory_2_outlined),
                        ),
                        title: Text(produto.nome),
                        subtitle: Text(
                          'Cliente: ${cliente?.nome ?? 'Não encontrado'}\n'
                          'Unidade: ${produto.unidade}\n'
                          'Valor: R\$ ${produto.valor.toStringAsFixed(2).replaceAll('.', ',')}'
                          '${produto.indice.isNotEmpty ? '\nÍndice: ${produto.indice}' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Ações do produto',
                          onSelected: (acao) {
                            if (acao == 'editar') {
                              _editarProduto(produto);
                            } else if (acao == 'excluir') {
                              _excluirProduto(produto);
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
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
