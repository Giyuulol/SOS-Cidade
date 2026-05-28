String formatarDataHora(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
}

String formatarTempoDecorrido(DateTime abertoEm, DateTime agora) {
  final difference = agora.difference(abertoEm);

  if (difference.inMinutes < 1) {
    return 'Aberto agora';
  }
  if (difference.inHours < 1) {
    return 'Aberto há ${difference.inMinutes} min';
  }
  if (difference.inDays < 1) {
    return 'Aberto há ${difference.inHours} h';
  }
  return 'Aberto há ${difference.inDays} d';
}
