import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chamados_filter.dart';
import 'chamados_providers.dart';

final chamadosFilterProvider =
    NotifierProvider<ChamadosFilterController, ChamadosFilter>(
      ChamadosFilterController.new,
    );

final chamadosFiltradosProvider = Provider((ref) {
  final filter = ref.watch(chamadosFilterProvider);
  final chamadosAsync = ref.watch(chamadosControllerProvider);

  return chamadosAsync.whenData(
    (chamados) => chamados.where(filter.matches).toList(growable: false),
  );
});

final class ChamadosFilterController extends Notifier<ChamadosFilter> {
  @override
  ChamadosFilter build() {
    return const ChamadosFilter();
  }

  void updateSearchTerm(String value) {
    state = state.copyWith(searchTerm: value);
  }

  void clear() {
    state = const ChamadosFilter();
  }
}
