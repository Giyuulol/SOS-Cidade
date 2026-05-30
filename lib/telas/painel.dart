import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chamado.dart';
import '../provedores/chamado_provider.dart';
import '../utilitarios/formatadores_data.dart';
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

    final total = chamados.length;
    final abertos = chamados
        .where((chamado) => chamado.status == 'Aberto')
        .length;
    final andamento = chamados
        .where((chamado) => chamado.status == 'Em Andamento')
        .length;
    final concluidos = chamados
        .where((chamado) => chamado.status == 'Concluído')
        .length;
    final criticos = chamados
        .where((chamado) => chamado.prioridade == 'Crítica')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Cidade'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                formatarDataHora(_now),
                style: Theme.of(context).textTheme.labelLarge,
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
            if (criticos > 5)
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
            if (criticos > 5) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Abertos',
                    value: abertos,
                    icon: Icons.mark_email_unread_outlined,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'Andamento',
                    value: andamento,
                    icon: Icons.sync,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'Concluídos',
                    value: concluidos,
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'Críticos',
                    value: criticos,
                    icon: Icons.report_outlined,
                    color: Colors.red,
                  ),
                ),
              ],
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

  static const List<String> _statusDisponiveis = [
    'Aberto',
    'Em Andamento',
    'Concluído',
  ];

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(chamado.prioridade);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: priorityColor.withValues(alpha: 0.12),
          child: Icon(_categoryIcon(chamado.categoria), color: priorityColor),
        ),
        title: Text(chamado.titulo),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${chamado.categoria} • ${chamado.bairro}'),
              const SizedBox(height: 2),
              Text(
                '${formatarTempoDecorrido(chamado.dataAbertura, currentDateTime)} • ${formatarDataHora(chamado.dataAbertura)}',
              ),
              const SizedBox(height: 2),
              Text('Status: ${chamado.status}'),
            ],
          ),
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TelaCadastro(chamado: chamado)),
          );
        },
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Corrigido aqui
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Chip(
                label: Text(chamado.prioridade),
                backgroundColor: priorityColor.withValues(alpha: 0.12),
                side: BorderSide(color: priorityColor.withValues(alpha: 0.25)),
                labelStyle: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (chamado.status == 'Concluído')
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
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
                  ),
                )
              else
                PopupMenuButton<String>(
                  tooltip: 'Alterar status',
                  onSelected: onAlterarStatus,
                  itemBuilder: (context) => _statusDisponiveis
                      .map(
                        (status) =>
                            PopupMenuItem(value: status, child: Text(status)),
                      )
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
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
