# SOS Cidade - Desafio Missão Resgate Urbano 🚀

Este é o nosso aplicativo **SOS Cidade**, desenvolvido em Flutter para o desafio "Missão Resgate Urbano". Ele serve para cadastrar e acompanhar chamados de problemas na cidade (tipo buraco na rua, lâmpada queimada, vazamentos, etc.). Todos os dados ficam salvos direto no celular usando banco SQLite.

## O que o App faz:

- **Painel de Status (Dashboard)**: Mostra a quantidade de chamados (Abertos, Em andamento, Concluídos e Críticos) com cores amigáveis e indicadores de atividade.
- **Busca por Texto**: Campo de pesquisa rápida pra achar chamados pelo título ou descrição (com botão "X" pra limpar).
- **Filtro de Bairro**: Menu pra filtrar os chamados da lista pelo bairro selecionado.
- **Favoritos**: Botão de estrelinha amarela nos cards. Tem um botão de filtro rápido que mostra só os favoritos com o contador de quantos foram marcados.
- **Notificações**: Ícone de sininho no topo com contador vermelho. Abre uma listinha por baixo onde dá pra ver os avisos e "marcar todos como lidos". Favoritar um chamado avisa no sino, e desfavoritar remove o aviso sozinho.
- **Modo Escuro / Modo Claro**: Botão de alternar tema no canto do topo. O app lembra da sua escolha mesmo se você fechar e abrir ele de novo.
- **Data e Hora**: Exibida no canto inferior direito do cabeçalho.
- **Visual e Fonte**: Usa a fonte oficial **Rawline** (do GOV.BR) e tem animações de cascata suaves ao carregar a lista.
- **Regras do Jogo**: Chamados com o status "Concluído" não deixam mais ser editados e mostram um aviso de "Encerrado". Não deixa cadastrar dois chamados com títulos repetidos.

## Tecnologias que usamos:

- **Flutter / Dart** (Base do app)
- **Riverpod** (Pra controlar os estados da tela)
- **SQLite** (Pra guardar os dados e configurações)
- **Fonte Rawline** (Configurada localmente)

## Como rodar o projeto:

1. Instale as dependências:
   ```bash
   flutter pub get
   ```

2. Rode o app (com um celular ou emulador aberto):
   ```bash
   flutter run
   ```

3. Para rodar a nossa suíte de testes:
   ```bash
   flutter test
   ```

4. Para rodar a análise de qualidade do código:
   ```bash
   flutter analyze
   ```

## Estrutura do Banco (SQLite):
O banco de dados local se chama `sos_cidade.db` e contém:
- Tabela `chamados` (título, descrição, prioridade, bairro, se é favorito, etc.)
- Tabela `settings` (guarda a chave do tema escuro ou claro)
- Tabela `notificacoes` (guarda a mensagem da notificação e se já foi lida)
