import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chamado.dart';
import '../provedores/chamado_provider.dart';
import '../utilitarios/formatadores_data.dart';
import '../utilitarios/constantes.dart'; // <-- 1. Import adicionado aqui
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Cidade'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                formatarDataHora(_now),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TelaCadastro()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo chamado'),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.12),
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
                              style: Theme.of(context).textTheme.titleMedium
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
            const SizedBox(height: 24),
            Text('Chamados ', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...chamados.map(
              (chamado) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChamadoCard(
                  chamado: chamado,
                  currentDateTime: _now,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.total, required this.currentDateTime});

  final int total;
  final DateTime currentDateTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOS Cidade',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Data e hora: ${formatarDataHora(currentDateTime)}'),
            const SizedBox(height: 4),
            Text('Total de chamados: $total'),
          ],
        ),
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
    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
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
  });

  final Chamado chamado;
  final DateTime currentDateTime;
  final ValueChanged<String> onAlterarStatus;

  // 2. A lista manual _statusDisponiveis foi apagada daqui.

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

              // 3. O parâmetro status foi adicionado na função de tempo
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
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      )
                    : PopupMenuButton<String>(
                        tooltip: 'Alterar status',
                        onSelected: onAlterarStatus,

                        // 4. Usando a central de constantes no menu
                        itemBuilder: (context) => ConstantesChamado.status
                            .map(
                              (status) => PopupMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Mudar status',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
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
