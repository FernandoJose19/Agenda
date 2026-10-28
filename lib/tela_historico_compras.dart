
import 'package:flutter/material.dart';

import 'armazenamento_local.dart';
import 'venda.dart';

/// Tela para consultar o histórico de compras.
class TelaHistoricoCompras extends StatefulWidget {
  const TelaHistoricoCompras({super.key});

  @override
  State<TelaHistoricoCompras> createState() =>
      _TelaHistoricoComprasState();
}

class _TelaHistoricoComprasState
    extends State<TelaHistoricoCompras> {
  List<Venda> _vendas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarVendas();
  }

  /// Carrega as compras armazenadas localmente.
  Future<void> _carregarVendas() async {
    try {
      final vendas = await ArmazenamentoLocal.carregarVendas();

      if (!mounted) return;

      setState(() {
        _vendas = vendas;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar o histórico.'),
        ),
      );
    }
  }

  String _moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  /// Exibe os detalhes de uma compra.
  void _mostrarDetalhes(Venda venda) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes da compra'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detalhe('Cliente', venda.nomeCliente),
                  _detalhe('Vendedor', venda.vendedor),
                  _detalhe('Data', _formatarData(venda.data)),
                  const Divider(height: 24),
                  const Text(
                    'Produtos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...venda.itens.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nomeProduto,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${item.quantidade} ${item.unidade} × '
                            '${_moeda(item.valorUnitario)}',
                          ),
                          Text(
                            'Subtotal: ${_moeda(item.subtotal)}',
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _moeda(venda.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detalhe(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Exclui uma compra após confirmação.
  Future<void> _excluirVenda(Venda venda) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir compra'),
        content: Text(
          'Deseja excluir a compra de ${venda.nomeCliente}, '
          'realizada em ${_formatarData(venda.data)}?',
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

    final vendasAtualizadas = _vendas
        .where((item) => item.id != venda.id)
        .toList();

    try {
      await ArmazenamentoLocal.salvarVendas(vendasAtualizadas);

      if (!mounted) return;

      setState(() => _vendas = vendasAtualizadas);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra excluída do histórico.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir a compra.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendasOrdenadas = [..._vendas]
      ..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar histórico',
            onPressed: _carregarVendas,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _vendas.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma compra registrada.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'As compras concluídas aparecerão aqui.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vendasOrdenadas.length,
                  itemBuilder: (context, index) {
                    final venda = vendasOrdenadas[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long),
                        ),
                        title: Text(
                          venda.nomeCliente,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data: ${_formatarData(venda.data)}',
                              ),
                              Text('Vendedor: ${venda.vendedor}'),
                              Text(
                                'Itens: ${venda.itens.length}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${_moeda(venda.total)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Ações da compra',
                          onSelected: (acao) {
                            if (acao == 'detalhes') {
                              _mostrarDetalhes(venda);
                            } else if (acao == 'excluir') {
                              _excluirVenda(venda);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'detalhes',
                              child: Text('Ver detalhes'),
                            ),
                            PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir compra'),
                            ),
                          ],
                        ),
                        onTap: () => _mostrarDetalhes(venda),
                      ),
                    );
                  },
                ),
    );
  }
}
