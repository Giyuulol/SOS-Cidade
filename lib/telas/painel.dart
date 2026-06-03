import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chamado.dart';
import '../provedores/chamado_provider.dart';
import '../provedores/tema_provider.dart';
import '../provedores/notificacao_provider.dart';
import '../utilitarios/formatadores_data.dart';
import '../utilitarios/constantes.dart';
import 'cadastro.dart';

class TelaPainel extends ConsumerStatefulWidget {
  const TelaPainel({super.key});

  @override
  ConsumerState<TelaPainel> createState() => _EstadoTelaPainel();
}

class _EstadoTelaPainel extends ConsumerState<TelaPainel> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(chamadoProvider);
    final chamados = provider.chamados;
    final total = provider.total;
    final abertos = provider.abertos;
    final andamento = provider.emAndamento;
    final concluidos = provider.concluidos;
    final criticos = provider.criticos;
    final exibirAlertaCritico = provider.exibirAlertaCritico;
    final tema = ref.watch(temaProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Notificações',
          icon: Badge(
            isLabelVisible: ref.watch(notificacaoProvider).naoLidas > 0,
            label: Text('${ref.watch(notificacaoProvider).naoLidas}'),
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => _showNotificationsBottomSheet(context, ref),
        ),
        title: Text(
          'SOS Cidade',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: tema.isDarkMode ? 'Ativar modo claro' : 'Ativar modo escuro',
            icon: Icon(
              tema.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(temaProvider).alternarTema(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TelaCadastro()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo chamado'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
          children: [
            _HeaderSummary(total: total, currentDateTime: _now),
            const SizedBox(height: 12),
            if (exibirAlertaCritico)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alerta crítico',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Existem $criticos chamados com prioridade Crítica. Priorize a análise e a resposta.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (exibirAlertaCritico) const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;

                return GridView.count(
                  crossAxisCount: isCompact ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: isCompact ? 1.35 : 1,
                  children: [
                    _StatCard(
                      title: 'Abertos',
                      value: abertos,
                      icon: Icons.mark_email_unread_outlined,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Em andamento',
                      value: andamento,
                      icon: Icons.sync,
                      color: Colors.amber,
                    ),
                    _StatCard(
                      title: 'Concluídos',
                      value: concluidos,
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Críticos',
                      value: criticos,
                      icon: Icons.report_outlined,
                      color: Colors.red,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const _FiltrosBuscaSeccao(),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Chamados ', style: Theme.of(context).textTheme.titleLarge),
                if (provider.buscaQuery.isNotEmpty ||
                    provider.filtroBairro.isNotEmpty ||
                    provider.apenasFavoritos)
                  Text(
                    ' (${chamados.length} encontrados)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (chamados.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum chamado encontrado com os filtros ativos.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ...chamados.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final chamado = entry.value;
                return AnimatedCard(
                  key: ValueKey(chamado.id),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChamadoCard(
                      chamado: chamado,
                      currentDateTime: _now,
                      onToggleFavorite: () async {
                        await ref.read(chamadoProvider).alternarFavorito(chamado);
                      },
                      onAlterarStatus: (novoStatus) async {
                        if (novoStatus == chamado.status) return;

                        final providerRead = ref.read(chamadoProvider);
                        final messenger = ScaffoldMessenger.of(context);
                        final atualizado = chamado.copyWith(status: novoStatus);
                        await providerRead.atualizarChamado(atualizado);

                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status atualizado para $novoStatus em ${chamado.titulo}.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final notifProvider = ref.watch(notificacaoProvider);
            final lista = notifProvider.notificacoes;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notificações',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (lista.any((n) => !n.lido))
                        TextButton.icon(
                          onPressed: () {
                            ref.read(notificacaoProvider).marcarTodasComoLidas();
                          },
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Ler tudo'),
                        ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: lista.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Nenhuma notificação por enquanto.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: lista.length,
                            itemBuilder: (context, idx) {
                              final n = lista[idx];
                              return Card(
                                color: n.lido
                                    ? null
                                    : Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.15),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    n.mensagem,
                                    style: TextStyle(
                                      fontWeight:
                                          n.lido ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      formatarDataHora(n.data),
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.total, required this.currentDateTime});

  final int total;
  final DateTime currentDateTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Painel de Controle',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestão e monitoramento urbano em tempo real',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$total no total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  formatarDataHora(currentDateTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.12 : 0.08),
            color.withValues(alpha: isDark ? 0.03 : 0.01),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.04 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: value > 0 ? 0.8 : 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChamadoCard extends StatelessWidget {
  const _ChamadoCard({
    required this.chamado,
    required this.currentDateTime,
    required this.onAlterarStatus,
    required this.onToggleFavorite,
  });

  final Chamado chamado;
  final DateTime currentDateTime;
  final ValueChanged<String> onAlterarStatus;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(chamado.prioridade);
    final isConcluido = chamado.status == 'Concluído';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: isConcluido
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TelaCadastro(chamado: chamado),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: priorityColor.withValues(alpha: 0.12),
                    child: Icon(
                      _categoryIcon(chamado.categoria),
                      color: priorityColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chamado.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      chamado.favorito ? Icons.star : Icons.star_border,
                      color: chamado.favorito ? Colors.amber : null,
                    ),
                    onPressed: onToggleFavorite,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(chamado.prioridade),
                    backgroundColor: priorityColor.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: priorityColor.withValues(alpha: 0.25),
                    ),
                    labelStyle: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Categoria: ${chamado.categoria}'),
              const SizedBox(height: 4),
              Text('Bairro: ${chamado.bairro}'),
              const SizedBox(height: 4),
              Text('Data: ${formatarDataHora(chamado.dataAbertura)}'),
              const SizedBox(height: 4),
              Text(
                formatarTempoDecorrido(
                  chamado.dataAbertura,
                  currentDateTime,
                  status: chamado.status,
                ),
              ),
              const SizedBox(height: 4),
              Text('Status: ${chamado.status}'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: isConcluido
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Encerrado',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      )
                    : _MenuAlterarStatus(
                        statusAtual: chamado.status,
                        onAlterarStatus: onAlterarStatus,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Trânsito':
        return Icons.traffic;
      case 'Iluminação':
        return Icons.lightbulb_outline;
      case 'Saneamento':
        return Icons.water_drop_outlined;
      case 'Segurança':
        return Icons.shield_outlined;
      case 'Limpeza Urbana':
        return Icons.delete_outline;
      case 'Desastre Natural':
        return Icons.nature_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Crítica':
        return Colors.red;
      case 'Alta':
        return Colors.orange;
      case 'Média':
        return Colors.amber;
      case 'Baixa':
      default:
        return Colors.green;
    }
  }
}

class _MenuAlterarStatus extends StatelessWidget {
  const _MenuAlterarStatus({
    required this.statusAtual,
    required this.onAlterarStatus,
  });

  final String statusAtual;
  final ValueChanged<String> onAlterarStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      menuChildren: ConstantesChamado.status
          .map(
            (status) => MenuItemButton(
              onPressed: status == statusAtual ? null : () => onAlterarStatus(status),
              child: Text(status),
            ),
          )
          .toList(),
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.outline),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          iconAlignment: IconAlignment.end,
          label: const Text('Mudar status'),
        );
      },
    );
  }
}

class _FiltrosBuscaSeccao extends ConsumerStatefulWidget {
  const _FiltrosBuscaSeccao();

  @override
  ConsumerState<_FiltrosBuscaSeccao> createState() => _EstadoFiltrosBuscaSeccao();
}

class _EstadoFiltrosBuscaSeccao extends ConsumerState<_FiltrosBuscaSeccao> {
  late final TextEditingController _buscaController;

  @override
  void initState() {
    super.initState();
    _buscaController = TextEditingController(
      text: ref.read(chamadoProvider).buscaQuery,
    );
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(chamadoProvider);
    final bairros = provider.bairrosDisponiveis;

    // Sincroniza o controller com o estado do provider se mudar externamente
    if (_buscaController.text != provider.buscaQuery) {
      _buscaController.text = provider.buscaQuery;
      _buscaController.selection = TextSelection.fromPosition(
        TextPosition(offset: _buscaController.text.length),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _buscaController,
              onChanged: (val) => ref.read(chamadoProvider).buscaQuery = val,
              decoration: InputDecoration(
                hintText: 'Buscar chamados por título ou descrição...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.buscaQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          ref.read(chamadoProvider).buscaQuery = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: provider.filtroBairro.isEmpty ? null : provider.filtroBairro,
                    decoration: InputDecoration(
                      labelText: 'Bairro',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Todos os bairros'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todos os bairros'),
                      ),
                      ...bairros.map(
                        (b) => DropdownMenuItem(value: b, child: Text(b)),
                      ),
                    ],
                    onChanged: (val) {
                      ref.read(chamadoProvider).filtroBairro = val ?? '';
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  selected: provider.apenasFavoritos,
                  showCheckmark: false,
                  avatar: Icon(
                    provider.apenasFavoritos ? Icons.star : Icons.star_border,
                    size: 18,
                    color: provider.apenasFavoritos ? Colors.amber : null,
                  ),
                  label: Text('Favoritos (${provider.favoritosTotal})'),
                  onSelected: (val) {
                    ref.read(chamadoProvider).apenasFavoritos = val;
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({super.key, required this.child, required this.index});
  final Widget child;
  final int index;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: (widget.index * 50).clamp(0, 300));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
