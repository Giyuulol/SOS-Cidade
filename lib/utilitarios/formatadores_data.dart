String formatarDataHora(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
}

String formatarTempoDecorrido(
  DateTime abertoEm,
  DateTime agora, {
  String status = 'Aberto',
}) {
  final difference = agora.difference(abertoEm);

  final prefixo = status == 'Concluído' ? 'Tempo de resolução:' : 'Aberto há';

  if (difference.inMinutes < 1) {
    return status == 'Concluído' ? '$prefixo < 1 min' : 'Aberto agora';
  }
  if (difference.inHours < 1) {
    return '$prefixo ${difference.inMinutes} min';
  }
  if (difference.inDays < 1) {
    return '$prefixo ${difference.inHours} h';
  }
  return '$prefixo ${difference.inDays} d';
}
