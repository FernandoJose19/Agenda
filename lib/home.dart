
import 'package:flutter/material.dart';

import 'tela_clientes.dart';
import 'tela_produtos.dart';
import 'tela_vendas.dart';
import 'tela_historico_compras.dart';

/// Menu principal do aplicativo.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro e Compras'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Icon(
                Icons.storefront,
                size: 72,
              ),
              const SizedBox(height: 12),
              Text(
                'Controle de compras',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 28),

              _botao(
                context,
                titulo: 'Clientes',
                descricao: 'Cadastrar e consultar clientes',
                icone: Icons.people_outline,
                destino: const TelaClientes(),
              ),
              const SizedBox(height: 12),

              _botao(
                context,
                titulo: 'Produtos',
                descricao: 'Cadastrar produtos',
                icone: Icons.inventory_2_outlined,
                destino: const TelaProdutos(),
              ),
              const SizedBox(height: 12),

              _botao(
                context,
                titulo: 'Compras / Vendas',
                descricao:
                    'Adicionar vários produtos e concluir compra',
                icone: Icons.shopping_cart_outlined,
                destino: const TelaVendas(),
              ),
              const SizedBox(height: 12),

              _botao(
                context,
                titulo: 'Histórico de Compras',
                descricao: 'Consultar compras anteriores',
                icone: Icons.history,
                destino: const TelaHistoricoCompras(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cria um cartão de navegação reutilizável.
  Widget _botao(
    BuildContext context, {
    required String titulo,
    required String descricao,
    required IconData icone,
    required Widget destino,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icone, size: 36),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(descricao),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => destino,
            ),
          );
        },
      ),
    );
  }
}
