# Cadastro e Compras

## 1. Sobre o projeto

O **Cadastro e Compras** é um aplicativo desenvolvido utilizando Flutter e Dart, com o objetivo de organizar o cadastro de clientes e produtos, registrar vendas e consultar o histórico de compras.

O projeto foi desenvolvido com foco na prática de programação, na construção de interfaces gráficas e na organização de informações por meio de diferentes telas e modelos de dados.

A aplicação possui um menu principal que permite acessar as funcionalidades de cadastro de clientes, cadastro de produtos, registro de vendas e histórico de compras.

## 2. Objetivo do projeto

Desenvolver uma aplicação que facilite o gerenciamento de clientes, produtos e vendas, permitindo registrar informações, realizar cálculos e consultar dados armazenados localmente.

### Objetivos específicos

- Implementar formulários para cadastro e edição de informações.
- Organizar os dados por meio de classes e modelos.
- Permitir a associação de produtos aos clientes cadastrados.
- Registrar vendas com quantidades e valores.
- Calcular subtotais e o valor total das vendas.
- Armazenar e recuperar informações localmente.
- Consultar o histórico das vendas realizadas.

## 3. Funcionalidades

### 3.1. Tela inicial

Apresenta o menu principal do aplicativo e permite acessar as demais telas.

### 3.2. Cadastro de clientes

Permite cadastrar clientes com informações como:

- Nome;
- CPF;
- Telefone;
- Apelido;
- Turma ou turno;
- Índice.

A tela também possui funcionalidades para editar e excluir registros cadastrados.

### 3.3. Cadastro de produtos

Permite cadastrar produtos e associá-los a um cliente.

As informações incluem:

- Cliente associado;
- Nome do produto;
- Unidade de medida;
- Valor unitário;
- Índice.

Também permite editar e excluir produtos existentes.

### 3.4. Registro de vendas

Permite selecionar um cliente, adicionar produtos e informar as quantidades vendidas.

A aplicação calcula os subtotais dos itens e o total da venda. O projeto também possui recursos para trabalhar com rascunhos de vendas.

### 3.5. Histórico de compras

Apresenta as vendas registradas e permite consultar os detalhes das operações realizadas.

A tela complementa o registro de vendas, facilitando a consulta das informações armazenadas.

## 4. Tecnologias utilizadas

- **Flutter:** framework utilizado para desenvolver a interface e a estrutura da aplicação.
- **Dart:** linguagem de programação utilizada na implementação das funcionalidades.
- **Material Design:** componentes visuais utilizados na construção das interfaces.
- **Shared Preferences:** pacote utilizado para o armazenamento local de informações.
- **JSON:** formato utilizado para converter objetos e listas em estruturas de dados serializáveis.

## 5. Organização dos arquivos

Os arquivos principais estão organizados no diretório `lib/`.

| Arquivo | Finalidade |
|---|---|
| `main.dart` | Inicializa o aplicativo e define sua configuração principal. |
| `home.dart` | Apresenta o menu principal e a navegação entre as telas. |
| `cliente.dart` | Define o modelo de dados dos clientes. |
| `produto.dart` | Define o modelo de dados dos produtos. |
| `venda.dart` | Define os modelos de venda e de itens vendidos. |
| `formatadores.dart` | Reúne formatadores para campos numéricos, CPF, telefone e valores monetários. |
| `armazenamento_local.dart` | Contém os métodos de armazenamento e recuperação dos dados. |
| `tela_clientes.dart` | Implementa a interface de cadastro de clientes. |
| `tela_produtos.dart` | Implementa a interface de cadastro de produtos. |
| `tela_vendas.dart` | Implementa a interface de registro de vendas. |
| `tela_historico_compras.dart` | Implementa a consulta ao histórico de vendas. |

## 6. Armazenamento de dados

O aplicativo utiliza o pacote `shared_preferences` para armazenar informações localmente.

Os dados dos clientes, produtos e vendas são convertidos para JSON antes de serem armazenados. Quando necessário, essas informações são recuperadas e convertidas novamente em objetos utilizados pela aplicação.

Essa abordagem permite manter os dados entre execuções do aplicativo sem exigir, para esse armazenamento, a configuração de um servidor externo.

O armazenamento local utilizado neste projeto não substitui necessariamente um banco de dados relacional em aplicações que exigem maior volume de informações, consultas complexas ou acesso simultâneo por diferentes usuários.

## 7. Exemplos de código

### 7.1. Controle de campos de texto

O projeto utiliza `TextEditingController` para acessar e controlar os valores informados nos formulários.

```dart
final _nomeController = TextEditingController();
```

Esse controlador permite recuperar o nome digitado pelo usuário e utilizá-lo no cadastro do cliente ou produto.

### 7.2. Cálculo do subtotal

O subtotal de um item pode ser calculado multiplicando a quantidade pelo valor unitário.

```dart
double get subtotal => quantidade * valorUnitario;
```

Esse cálculo é utilizado para determinar o valor correspondente à quantidade de cada produto incluído na venda.

### 7.3. Navegação entre telas

A navegação permite abrir uma tela a partir de outra.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TelaClientes(),
  ),
);
```

Esse exemplo demonstra como abrir a tela de cadastro de clientes utilizando os recursos de navegação do Flutter.

## 8. Dificuldades encontradas durante o desenvolvimento

Durante o desenvolvimento e a revisão do código, foram identificados problemas que exigiram análise e correção.

### 8.1. Importação de bibliotecas

Foi identificado um erro relacionado ao tipo `TextInputFormatter`, utilizado para configurar a entrada de dados nos campos de texto.

A mensagem apresentada foi:

`The name 'TextInputFormatter' isn't a type, so it can't be used as a type argument.`

O problema estava relacionado à ausência da importação da biblioteca que disponibiliza esse tipo.

A correção consistiu em adicionar:

```dart
import 'package:flutter/services.dart';
```

Essa situação demonstrou a importância de verificar as dependências e as bibliotecas necessárias para utilizar os recursos do Flutter.

### 8.2. Formatação de valores monetários

Outro problema identificado ocorreu durante a edição de produtos.

Um produto cadastrado com o valor de R$ 23,00 podia apresentar o número 2300 no campo de edição. Ao salvar o produto novamente, o valor poderia ser interpretado incorretamente como R$ 2.300,00.

O problema estava relacionado à conversão do valor numérico para texto e ao funcionamento do `ValorMonetarioFormatter`.

A atribuição direta de um texto ao controlador não executa automaticamente o formatador de entrada. Por isso, foi necessário analisar como o valor era preparado para a edição e como o método de salvamento convertia o texto novamente em número.

A correção deve garantir que o valor seja apresentado no formato monetário brasileiro e que a conversão durante o salvamento preserve o valor original.

### 8.3. Testes e validação

Além dos problemas identificados, foi necessário considerar a validação dos formulários, a consistência dos dados e a compatibilidade entre os métodos de armazenamento e recuperação.

Esses aspectos devem ser verificados por meio de testes para assegurar que as funcionalidades trabalhem corretamente em conjunto.

## 9. Como executar o projeto

### Pré-requisitos

Para executar a aplicação, é necessário ter:

- Flutter SDK instalado;
- Dart SDK compatível, disponibilizado com o Flutter;
- Um dispositivo conectado ou emulador configurado;
- Git instalado, caso o projeto seja obtido por meio de um repositório.

### Passo 1 — Clonar o repositório

Substitua `USUARIO` pelo nome de usuário do GitHub e `REPOSITORIO` pelo nome do repositório criado.

```bash
git clone https://github.com/USUARIO/REPOSITORIO.git
```

### Passo 2 — Acessar a pasta do projeto

```bash
cd REPOSITORIO
```

### Passo 3 — Instalar as dependências

```bash
flutter pub get
```

Esse comando baixa as dependências declaradas no arquivo `pubspec.yaml`.

### Passo 4 — Verificar a instalação

```bash
flutter doctor
```

Esse comando verifica a configuração do ambiente Flutter e informa possíveis problemas de instalação.

### Passo 5 — Executar a aplicação

```bash
flutter run
```

O comando inicia o aplicativo em um dispositivo ou emulador compatível.

## 10. Possíveis melhorias futuras

Entre as melhorias que podem ser consideradas em versões futuras estão:

- Implementação de um banco de dados estruturado.
- Criação de mecanismos de backup e restauração.
- Aprimoramento dos relatórios de vendas.
- Implementação de filtros e pesquisas.
- Ampliação dos testes automatizados.
- Melhoria das validações dos formulários.
- Implementação de autenticação e controle de acesso, caso necessário.

Essas melhorias representam possibilidades de evolução e não funcionalidades necessariamente implementadas na versão atual.

## 11. Considerações finais

O desenvolvimento do Cadastro e Compras permitiu aplicar conceitos de programação em Dart e Flutter, incluindo construção de interfaces, navegação entre telas, manipulação de formulários, modelagem de dados, cálculos e armazenamento local.

O processo também evidenciou a importância da depuração, da leitura de mensagens de erro e da realização de testes durante a implementação das funcionalidades.

As dificuldades encontradas, especialmente relacionadas às importações e à formatação dos valores monetários, contribuíram para compreender melhor o funcionamento do código e a necessidade de manter consistentes as operações de entrada, edição e armazenamento de dados.

## 12. Autor

**Nome:** [Preencha com seu nome]

**Repositório GitHub:** [Insira o link público do repositório]

**Projeto:** Cadastro e Compras
