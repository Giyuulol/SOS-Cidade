import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_controller.dart';
import '../../../../core/theme/theme_providers.dart';
import '../../application/chamados_filter_provider.dart';
import '../../application/chamados_providers.dart';
import '../../application/chamados_controller.dart';
import '../../domain/chamado.dart';
import '../../domain/chamado_enums.dart';
import '../widgets/chamados_filter_panel.dart';
import '../widgets/chamados_search_bar.dart';
import 'novo_chamado_page.dart';

final class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationInitializationProvider);

    final chamadosAsync = ref.watch(chamadosFiltradosProvider);
    final metrics = ref.watch(chamadosMetricsProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Cidade'),
        actions: [
          IconButton(
            tooltip: themeMode == AppThemeMode.dark
                ? 'Ativar tema claro'
                : 'Ativar tema escuro',
            onPressed: ref
                .read(themeControllerProvider.notifier)
                .toggleLightDark,
            icon: Icon(
              themeMode == AppThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const NovoChamadoPage()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Chamado'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(chamadosControllerProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DashboardHeader(total: metrics.total),
              const SizedBox(height: 16),
              if (metrics.hasCriticalOverflow) ...[
                _CriticalOverflowAlert(count: metrics.criticos),
                const SizedBox(height: 16),
              ],
              ChamadosFilterPanel(metrics: metrics),
              const SizedBox(height: 16),
              const ChamadosSearchBar(),
              const SizedBox(height: 16),
              chamadosAsync.when(
                data: (chamados) => _ChamadosList(chamados: chamados),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => _ErrorState(error: error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Painel de chamados',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year} '
          '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '$total chamados registrados',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

final class _CriticalOverflowAlert extends StatelessWidget {
  const _CriticalOverflowAlert({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(
            Icons.priority_high_outlined,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Alerta: existem $count chamados críticos registrados.',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ChamadosList extends ConsumerWidget {
  const _ChamadosList({required this.chamados});

  final List<Chamado> chamados;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chamados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('Nenhum chamado encontrado.')),
      );
    }

    return Column(
      children: [
        for (final chamado in chamados) ...[
          _ChamadoCard(
            chamado: chamado,
            onStatusChanged: (status) => _updateStatus(
              context: context,
              controller: ref.read(chamadosControllerProvider.notifier),
              chamado: chamado,
              status: status,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required ChamadosController controller,
    required Chamado chamado,
    required ChamadoStatus status,
  }) async {
    try {
      await controller.updateStatus(chamado: chamado, status: status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status alterado para ${status.label}.')),
      );
    } on StateError catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

final class _ChamadoCard extends StatelessWidget {
  const _ChamadoCard({required this.chamado, required this.onStatusChanged});

  final Chamado chamado;
  final ValueChanged<ChamadoStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = _priorityColor(chamado.prioridade, colorScheme);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor.withValues(alpha: 0.12),
          foregroundColor: priorityColor,
          child: Icon(_categoryIcon(chamado.categoria)),
        ),
        title: Text(
          chamado.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${chamado.categoria.label} - ${chamado.bairro}'),
              const SizedBox(height: 4),
              Text(
                '${chamado.status.label} | ${chamado.prioridade.label} | '
                '${_twoDigits(chamado.data.day)}/${_twoDigits(chamado.data.month)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Aberto há ${_formatDuration(chamado.tempoDesdeAbertura())}',
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chamado.isCritico) ...[
              Tooltip(
                message: 'Chamado crítico',
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(width: 4),
            ],
            _ChamadoStatusAction(
              chamado: chamado,
              onStatusChanged: onStatusChanged,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ChamadoStatusAction extends StatelessWidget {
  const _ChamadoStatusAction({
    required this.chamado,
    required this.onStatusChanged,
  });

  final Chamado chamado;
  final ValueChanged<ChamadoStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (chamado.status == ChamadoStatus.concluido) {
      return Tooltip(
        message: 'Chamado concluído não pode ser editado',
        child: Icon(Icons.lock_outline, color: colorScheme.outline),
      );
    }

    return PopupMenuButton<ChamadoStatus>(
      tooltip: 'Alterar status',
      initialValue: chamado.status,
      icon: const Icon(Icons.edit_outlined),
      onSelected: (status) {
        if (status != chamado.status) onStatusChanged(status);
      },
      itemBuilder: (context) {
        return [
          for (final status in ChamadoStatus.values)
            PopupMenuItem(value: status, child: Text(status.label)),
        ];
      },
    );
  }
}

final class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Não foi possível carregar os chamados: $error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

IconData _categoryIcon(ChamadoCategoria categoria) {
  return switch (categoria) {
    ChamadoCategoria.transito => Icons.traffic_outlined,
    ChamadoCategoria.iluminacao => Icons.lightbulb_outline,
    ChamadoCategoria.saneamento => Icons.water_drop_outlined,
    ChamadoCategoria.seguranca => Icons.security_outlined,
    ChamadoCategoria.limpezaUrbana => Icons.delete_outline,
    ChamadoCategoria.desastreNatural => Icons.flood_outlined,
  };
}

Color _priorityColor(ChamadoPrioridade prioridade, ColorScheme colorScheme) {
  return switch (prioridade) {
    ChamadoPrioridade.baixa => Colors.green.shade700,
    ChamadoPrioridade.media => Colors.orange.shade700,
    ChamadoPrioridade.alta => colorScheme.primary,
    ChamadoPrioridade.critica => colorScheme.error,
  };
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
  }

  if (duration.inHours > 0) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
  }

  final minutes = duration.inMinutes;
  return minutes <= 0 ? 'menos de 1min' : '${minutes}min';
}