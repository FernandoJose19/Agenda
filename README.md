# DESENVOLVIMENTO DO APLICATIVO AGENDA

**Tecnologia utilizada:** Flutter e Dart  
**Tipo de aplicação:** Aplicativo de cadastro e gerenciamento de compras  
**Objetivo:** Desenvolver um aplicativo que permita cadastrar clientes e produtos, registrar vendas e consultar o histórico de compras.

---

# PÁGINA 1 — INTRODUÇÃO E OBJETIVOS DO PROJETO

## 1. Introdução

O projeto consiste no desenvolvimento de um aplicativo chamado **Cadastro e Compras**, utilizando o framework Flutter e a linguagem de programação Dart.

A proposta do aplicativo é organizar informações de clientes e produtos e permitir o registro de vendas, incluindo quantidades, valores unitários e totais das compras.

Durante o desenvolvimento, foi necessário criar diferentes telas, organizar os dados em arquivos separados e implementar funcionalidades de cadastro, edição, exclusão e armazenamento local.

O processo também envolveu a identificação e a correção de erros de programação, especialmente relacionados à formatação de valores monetários, à utilização de bibliotecas e ao preenchimento dos campos durante a edição de registros.

## 2. Objetivo geral

Desenvolver um aplicativo simples para gerenciar clientes, produtos e vendas, aplicando conceitos fundamentais de programação, organização de código e desenvolvimento de interfaces gráficas.

## 3. Objetivos específicos

- Criar uma tela inicial para acessar as funcionalidades do sistema.
- Permitir o cadastro e a edição de clientes.
- Permitir o cadastro e a edição de produtos.
- Associar produtos aos respectivos clientes.
- Registrar vendas com quantidades e valores.
- Calcular os subtotais dos produtos e o total das vendas.
- Armazenar informações localmente no dispositivo.
- Consultar o histórico de vendas realizadas.
- Identificar e corrigir erros encontrados durante os testes.

---

# PÁGINA 2 — TELA INICIAL E NAVEGAÇÃO

## 1. Arquivos utilizados

- `main.dart`
- `home.dart`

## 2. Finalidade da tela

A tela inicial funciona como o menu principal do aplicativo. Ela permite que o usuário acesse as funcionalidades sem precisar navegar manualmente pelos arquivos do projeto.

O arquivo `main.dart` inicializa a aplicação, enquanto `home.dart` organiza os botões e as opções disponíveis.

## 3. Exemplo de código

```dart
void main() {
  runApp(const MeuAplicativo());
}
```

Esse trecho representa a inicialização típica de uma aplicação Flutter: a função `main()` executa `runApp()`, que apresenta o componente principal na tela.

No arquivo `home.dart`, a navegação pode ser feita por meio de um botão:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TelaClientes(),
  ),
);
```

O objetivo desse código é abrir a tela de cadastro de clientes quando o usuário seleciona a opção correspondente.

## 4. Dificuldades de desenvolvimento

Uma das preocupações dessa etapa é garantir que as telas estejam corretamente importadas e que os nomes das classes correspondam aos utilizados nos arquivos.

Por exemplo, se o código tentar abrir uma classe chamada `TelaCliente`, mas a classe criada se chamar `TelaClientes`, o compilador poderá apresentar um erro de identificação.

**Importância da etapa:** centralizar o acesso às funcionalidades e tornar a utilização do aplicativo mais simples.

---

# PÁGINA 3 — CADASTRO DE CLIENTES

## 1. Arquivo utilizado

`lib/tela_clientes.dart`

O cadastro de clientes permite registrar informações como nome, CPF, telefone, apelido, turma ou turno e índice, conforme os campos definidos no projeto.

A tela utiliza campos de texto para receber os dados e botões para salvar, editar e excluir registros.

## 2. Exemplo de código

```dart
final _nomeController = TextEditingController();
```

O `TextEditingController` permite acessar e controlar o texto digitado pelo usuário. Nesse caso, ele é utilizado para obter o nome informado no formulário.

Outro exemplo é a validação de um campo obrigatório:

```dart
if (valor == null || valor.trim().isEmpty) {
  return 'Informe o nome do cliente.';
}
```

Esse trecho verifica se o campo está vazio ou contém apenas espaços, impedindo que o cadastro prossiga sem o nome.

## 3. Problema identificado durante o desenvolvimento

Foi identificado um erro de compilação relacionado ao tipo `TextInputFormatter`, utilizado para configurar a entrada de dados nos campos de texto.

A mensagem apresentada foi:

> The name 'TextInputFormatter' isn't a type, so it can't be used as a type argument.

O problema ocorreu porque faltava importar a biblioteca que contém esse tipo.

A correção foi adicionar o seguinte import:

```dart
import 'package:flutter/services.dart';
```

Esse exemplo demonstra a importância de importar as bibliotecas necessárias para utilizar os recursos do Flutter.

## 4. Objetivo da tela

Organizar os dados dos clientes e possibilitar sua utilização posteriormente no cadastro de produtos e no registro das vendas.

---

# PÁGINA 4 — CADASTRO DE PRODUTOS

## 1. Arquivo utilizado

`lib/tela_produtos.dart`

A tela de produtos permite cadastrar o nome do produto, sua unidade de medida, seu valor unitário, o índice e o cliente ao qual está associado.

Também oferece opções para editar e excluir produtos já cadastrados.

## 2. Exemplo de código

```dart
final produto = Produto(
  id: _produtoEmEdicao ??
      DateTime.now().microsecondsSinceEpoch.toString(),
  clienteId: _clienteSelecionado!,
  nome: _nomeController.text.trim(),
  unidade: _unidade,
  valor: valor,
  indice: _indiceController.text.trim(),
);
```

Esse trecho cria um objeto do tipo `Produto`, reunindo as informações preenchidas no formulário.

O operador `??` permite reutilizar o identificador de um produto durante a edição ou gerar um novo identificador durante um cadastro.

## 3. Problema real: formatação do valor monetário

Durante os testes, foi identificado um problema no campo de valor.

Ao cadastrar um produto por R$ 23,00, o valor era apresentado corretamente na lista. Entretanto, ao clicar em **Editar**, o campo passava a mostrar 2300. Quando o produto era salvo novamente, o valor podia ser registrado como R$ 2.300,00.

O problema estava relacionado à conversão do valor numérico para texto e ao funcionamento do `ValorMonetarioFormatter`.

O código de edição utilizava a seguinte operação:

```dart
_valorController.text =
    (produto.valor * 100).round().toString();
```

Essa multiplicação transforma o valor em centavos. Contudo, o texto atribuído diretamente ao controlador não passa automaticamente pelo formatador de entrada.

Assim, o número 23,00 era convertido em 2300 e exibido sem a formatação monetária esperada.

A correção exige que o valor seja convertido para o formato brasileiro antes de preencher o campo, mantendo a conversão do formulário compatível com o método de salvamento.

**Resultado esperado após a correção:** cadastrar R$ 23,00, editar o produto e salvá-lo novamente sem alterar seu valor.

---

# PÁGINA 5 — MODELOS E ORGANIZAÇÃO DOS DADOS

## 1. Arquivos utilizados

- `lib/cliente.dart`
- `lib/produto.dart`
- `lib/venda.dart`

Esses arquivos definem a estrutura dos dados utilizados pelo aplicativo.

Separar os modelos das telas evita que todas as informações e regras do sistema precisem ficar concentradas em um único arquivo.

## 2. Modelo de cliente

Exemplo simplificado:

```dart
class Cliente {
  final String id;
  final String nome;
  final String cpf;
  final String telefone;

  Cliente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
  });
}
```

O objetivo dessa estrutura é representar um cliente por meio de atributos definidos.

O identificador permite distinguir um registro de outro, mesmo quando dois clientes possuem nomes semelhantes.

## 3. Modelo de produto

O produto possui informações próprias e uma referência ao cliente associado.

```dart
class Produto {
  final String id;
  final String clienteId;
  final String nome;
  final double valor;

  // Demais campos e construtor.
}
```

O campo `clienteId` permite relacionar o produto a um cliente cadastrado.

O tipo `double` é utilizado para representar valores numéricos que possuem casas decimais.

## 4. Modelo de venda

O arquivo `venda.dart` contém as estruturas `Venda` e `ItemVenda`.

O item representa cada produto incluído em uma venda. Já a venda reúne os itens, o cliente, o vendedor, a data e o total calculado.

Um exemplo da lógica de subtotal é:

```dart
double get subtotal => quantidade * valorUnitario;
```

O subtotal é calculado multiplicando a quantidade do produto pelo seu valor unitário.

**Importância dessa organização:** facilitar a manutenção, a reutilização das informações e os cálculos realizados pelo sistema.

---

# PÁGINA 6 — FORMATAÇÃO DOS CAMPOS

## 1. Arquivo utilizado

`lib/formatadores.dart`

Esse arquivo reúne regras para controlar a entrada de informações nos campos de texto.

Entre os formatadores utilizados estão:

- `LimiteNumericoFormatter`: limita a quantidade de dígitos.
- `CpfFormatter`: organiza a apresentação do CPF.
- `TelefoneFormatter`: aplica a máscara de telefone.
- `ValorMonetarioFormatter`: formata os valores monetários.

## 2. Exemplo de utilização

```dart
inputFormatters: [
  ValorMonetarioFormatter(),
],
```

Esse trecho é utilizado em um campo de texto para aplicar o formatador monetário durante a digitação.

A finalidade é evitar que o usuário precise inserir manualmente todos os símbolos de formatação.

## 3. Dificuldade encontrada

A formatação monetária exige atenção porque existem duas situações diferentes:

1. O usuário está digitando um novo valor.
2. O sistema está carregando um valor já cadastrado para edição.

Na primeira situação, o formatador atua durante a entrada de texto. Na segunda, o programa precisa preparar o texto corretamente antes de atribuí-lo ao controlador.

Essa diferença foi importante para compreender por que um valor aparentemente correto podia ser alterado ao entrar no modo de edição.

**Objetivo da etapa:** padronizar os dados digitados e melhorar a apresentação das informações ao usuário.

---

# PÁGINA 7 — ARMAZENAMENTO LOCAL E HISTÓRICO DE VENDAS

## 1. Arquivos utilizados

- `lib/armazenamento_local.dart`
- `lib/tela_historico_compras.dart`

O arquivo `armazenamento_local.dart` reúne os métodos responsáveis por salvar e carregar os dados utilizando o pacote `shared_preferences`.

O arquivo `tela_historico_compras.dart` apresenta as vendas registradas e permite consultar seus detalhes.

## 2. Exemplo de código

```dart
final dados = jsonEncode(
  produtos.map((produto) => produto.toJson()).toList(),
);
```

Esse exemplo converte uma lista de produtos para uma representação JSON, que pode ser armazenada como texto.

A conversão inversa permite recuperar os dados posteriormente e reconstruir os objetos.

O armazenamento local é utilizado para manter informações entre as execuções do aplicativo, sem exigir que um servidor externo seja configurado para essa finalidade.

## 3. Histórico de compras

A tela de histórico apresenta as vendas realizadas e permite visualizar informações como cliente, data, produtos, quantidades e valores.

Essa funcionalidade complementa o registro das vendas, possibilitando consultar operações anteriores.

## 4. Cuidados necessários

Os métodos de gravação e leitura precisam utilizar as mesmas chaves de armazenamento e estruturas de dados compatíveis.

Além disso, é importante testar se os dados permanecem disponíveis depois que o aplicativo é fechado e aberto novamente.

**Objetivo da etapa:** possibilitar a persistência local das informações e a consulta das vendas registradas.

---

# PÁGINA 8 — TELA DE VENDAS, TESTES E CONSIDERAÇÕES FINAIS

## 1. Arquivo utilizado

`lib/tela_vendas.dart`

A tela de vendas reúne os dados necessários para registrar uma compra.

Entre suas funcionalidades estão a seleção do cliente, a inclusão de produtos, a definição de quantidades, o cálculo dos valores e a conclusão da venda.

O arquivo também utiliza recursos para salvar e recuperar um rascunho da operação.

## 2. Exemplo de código

```dart
final valorTotal = itens.fold<double>(
  0,
  (total, item) => total + item.subtotal,
);
```

Esse é um exemplo de cálculo de total a partir de uma lista de itens. O método `fold` percorre os elementos e acumula os subtotais para obter o resultado final.

A lógica de cálculo é importante para que o valor total corresponda à soma dos produtos incluídos na venda.

## 3. Testes e dificuldades do desenvolvimento

Durante o desenvolvimento e a revisão do código, foram considerados os seguintes pontos de atenção:

| Situação | Importância da verificação |
|---|---|
| Importação de bibliotecas | Evitar erros de compilação causados por tipos não reconhecidos. |
| Edição de clientes e produtos | Garantir que a edição atualize o registro correto. |
| Formatação monetária | Evitar alterações indevidas nos valores durante a edição. |
| Armazenamento local | Confirmar que os dados sejam recuperados corretamente. |
| Cálculos das vendas | Conferir subtotais e total geral. |
| Navegação entre telas | Garantir que as funcionalidades sejam acessíveis pelo menu. |

O erro de importação de `TextInputFormatter` e o problema de formatação do valor monetário foram identificados na conversa durante o desenvolvimento. Os demais itens representam verificações importantes para o projeto, e não necessariamente erros que tenham ocorrido de fato.

## 4. Considerações finais

O desenvolvimento do aplicativo Cadastro e Compras permitiu trabalhar com conceitos fundamentais do Flutter e da linguagem Dart, como classes, objetos, listas, controladores de texto, formulários, navegação entre telas e armazenamento local.

O projeto também demonstrou que a construção de um aplicativo não se limita à escrita do código. É necessário executar testes, interpretar mensagens de erro, investigar comportamentos inesperados e verificar se as correções preservam as demais funcionalidades.

Um dos principais desafios foi o tratamento dos valores monetários, pois o dado numérico armazenado e o texto apresentado no campo de edição possuem formatos diferentes. Esse problema evidenciou a importância de compreender a conversão de dados e o funcionamento dos formatadores.

Conclui-se que o desenvolvimento foi uma oportunidade de aplicar conhecimentos de programação em uma situação prática, compreender melhor a organização de um projeto e desenvolver habilidades de identificação e resolução de problemas.

O resultado esperado é um aplicativo funcional, com telas organizadas, operações de cadastro e venda e armazenamento local das informações, respeitando os testes necessários para confirmar o funcionamento de cada recurso.
