import 'package:flutter/material.dart';

import '../../application/chamados_providers.dart';

final class ChamadosFilterPanel extends StatelessWidget {
  const ChamadosFilterPanel({super.key, required this.metrics});

  final ChamadosMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _MetricCard(
          label: 'Abertos',
          value: metrics.abertos,
          icon: Icons.mark_email_unread_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        _MetricCard(
          label: 'Em andamento',
          value: metrics.emAndamento,
          icon: Icons.pending_actions_outlined,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        _MetricCard(
          label: 'Concluídos',
          value: metrics.concluidos,
          icon: Icons.task_alt_outlined,
          color: Colors.green.shade700,
        ),
        _MetricCard(
          label: 'Críticos',
          value: metrics.criticos,
          icon: Icons.priority_high_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

final class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Text(
              '$value',
              style: textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
