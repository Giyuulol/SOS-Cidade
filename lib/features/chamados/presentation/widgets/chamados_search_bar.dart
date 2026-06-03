import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/chamados_filter_provider.dart';

final class ChamadosSearchBar extends ConsumerWidget {
  const ChamadosSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(chamadosFilterProvider);

    return TextField(
      onChanged: ref.read(chamadosFilterProvider.notifier).updateSearchTerm,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Buscar chamados',
        hintText: 'Título, descrição ou bairro',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: filter.searchTerm.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                onPressed: ref.read(chamadosFilterProvider.notifier).clear,
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}
