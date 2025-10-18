String getInitials(String name) {
  final words = name.split(' ');
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  } else if (words.isNotEmpty) {
    return words[0][0].toUpperCase();
  }
  return '?';
}

bool isValidYoutubeUrl(String url) {
  final regex = RegExp(
      r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$',
      caseSensitive: false);
  return regex.hasMatch(url);
}
