# SOS Cidade

O **SOS Cidade** é um aplicativo mobile desenvolvido em Flutter para registrar e
acompanhar chamados urbanos emergenciais. O objetivo é facilitar o gerenciamento
de problemas como buracos na rua, falta de iluminação, vazamentos, acidentes,
lixo acumulado, árvores caídas e enchentes.

O projeto foi desenvolvido como solução para o desafio **Missão Resgate Urbano**.
A aplicação funciona em Android e iOS e mantém os dados salvos localmente com
SQLite.

## Funcionalidades

- Dashboard com nome do aplicativo, data e hora atuais e total de chamados.
- Cards com quantidade de chamados abertos, em andamento, concluídos e críticos.
- Lista de chamados ordenada por prioridade.
- Cadastro e edição de chamados.
- Atualização rápida de status diretamente pelo dashboard.
- Ícones diferentes para cada categoria.
- Exibição do tempo decorrido desde a abertura do chamado.
- Alerta visual quando existem mais de 5 chamados críticos.
- Bloqueio de edição para chamados concluídos.
- Persistência local com SQLite.
- Layout responsivo para melhorar a visualização em diferentes tamanhos de tela.

## Regras de Negócio

- Chamados com prioridade crítica ou alta aparecem no topo da lista.
- Não é permitido cadastrar dois chamados com o mesmo título.
- Título, descrição, bairro e responsável são obrigatórios.
- Chamados concluídos não podem ser editados.
- A data de abertura e o status inicial são preenchidos automaticamente.
- Todo novo chamado começa com o status `Aberto`.
- O aplicativo calcula automaticamente o tempo desde a abertura.
- Um alerta visual é exibido quando existem mais de 5 chamados críticos.

## Categorias

- Trânsito
- Iluminação
- Saneamento
- Segurança
- Limpeza Urbana
- Desastre Natural

## Prioridades

- Baixa
- Média
- Alta
- Crítica

## Status

- Aberto
- Em Andamento
- Concluído

## Tecnologias Utilizadas

- **Flutter**: framework utilizado para criar o aplicativo mobile.
- **Dart**: linguagem utilizada no desenvolvimento.
- **Material 3**: componentes visuais e tema da interface.
- **Riverpod**: gerenciamento de estado.
- **SQLite**: persistência local dos chamados.

## Bibliotecas

As principais bibliotecas estão declaradas no arquivo `pubspec.yaml`:

| Biblioteca | Finalidade |
| --- | --- |
| `flutter_riverpod` | Gerenciamento de estado e atualização da interface |
| `sqflite` | Criação e acesso ao banco de dados SQLite |
| `path` | Montagem segura do caminho do arquivo do banco |
| `cupertino_icons` | Ícones no estilo iOS |
| `flutter_lints` | Regras de qualidade e padronização do código |
| `flutter_test` | Testes automatizados dos widgets |

## Arquitetura do Projeto

O código está organizado em camadas simples para separar as responsabilidades:

```text
lib/
├── database/
│   └── db_helper.dart
├── models/
│   └── chamado.dart
├── provedores/
│   └── chamado_provider.dart
├── telas/
│   ├── cadastro.dart
│   └── painel.dart
├── utilitarios/
│   └── formatadores_data.dart
└── main.dart
```

- `main.dart`: inicia o aplicativo, configura o tema e registra o Riverpod.
- `models/chamado.dart`: representa um chamado e converte seus dados para o
  formato utilizado pelo SQLite.
- `database/db_helper.dart`: cria o banco e executa operações de leitura,
  cadastro e atualização.
- `provedores/chamado_provider.dart`: concentra o estado dos chamados e aplica
  regras de negócio.
- `telas/painel.dart`: exibe o dashboard e a lista de chamados.
- `telas/cadastro.dart`: permite cadastrar e editar chamados.
- `utilitarios/formatadores_data.dart`: formata data, hora e tempo decorrido.

## Pré-requisitos

Antes de executar o projeto, é necessário instalar:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK, incluído na instalação do Flutter
- [Git](https://git-scm.com/downloads)
- Android Studio ou Xcode, dependendo da plataforma utilizada

Este projeto foi validado com:

```text
Flutter 3.41.9
Dart 3.11.5
```

Depois de instalar o Flutter, confirme se o ambiente está configurado:

```bash
flutter doctor
```

## Como Baixar o Projeto

Clone o repositório e entre na pasta:

```bash
git clone <URL_DO_REPOSITORIO>
cd SOS-Cidade
```

Instale as dependências:

```bash
flutter pub get
```

## Executar no Android

Para executar no Android:

1. Instale o Android Studio e o Android SDK.
2. Crie e inicialize um emulador pelo Device Manager ou conecte um aparelho com
   a depuração USB ativada.
3. Confira os dispositivos disponíveis:

```bash
flutter devices
```

4. Execute o aplicativo:

```bash
flutter run
```

Quando existir mais de um dispositivo conectado, informe o identificador:

```bash
flutter run -d <ID_DO_DISPOSITIVO>
```

## Executar no iOS

O desenvolvimento para iOS exige macOS e Xcode instalado.

1. Confira se o Xcode está configurado:

```bash
xcode-select -p
```

2. Instale as dependências nativas do iOS:

```bash
cd ios
pod install
cd ..
```

3. Abra o simulador:

```bash
open -a Simulator
```

4. Confira os dispositivos disponíveis:

```bash
flutter devices
```

5. Execute o aplicativo:

```bash
flutter run -d <ID_DO_SIMULADOR>
```

## Banco de Dados

Os chamados são armazenados localmente no arquivo `sos_cidade.db`. O banco é
criado automaticamente na primeira execução do aplicativo.

A tabela `chamados` possui os seguintes campos:

| Campo | Tipo | Descrição |
| --- | --- | --- |
| `id` | `INTEGER` | Identificador único |
| `titulo` | `TEXT` | Título único do chamado |
| `descricao` | `TEXT` | Detalhes do problema |
| `categoria` | `TEXT` | Tipo do problema urbano |
| `prioridade` | `TEXT` | Nível de urgência |
| `bairro` | `TEXT` | Bairro do chamado |
| `responsavel` | `TEXT` | Responsável pelo atendimento |
| `status` | `TEXT` | Situação atual |
| `dataAbertura` | `TEXT` | Data e hora de abertura |

Como o banco utiliza SQLite local, os dados continuam disponíveis após fechar e
abrir novamente o aplicativo.

## Verificação do Projeto

Para verificar a qualidade do código:

```bash
flutter analyze
```

Para executar os testes automatizados:

```bash
flutter test
```

## Plataformas Suportadas

- Android
- iOS

O projeto está focado na experiência mobile. A versão Web não está configurada.
