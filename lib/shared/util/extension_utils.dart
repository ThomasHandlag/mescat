extension UrlExtensions on String {
  bool get isValidYoutubeUrl {
    final youtubeRegex = RegExp(
      r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$',
      caseSensitive: false,
      multiLine: false,
    );
    return youtubeRegex.hasMatch(this);
  }

  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegex.hasMatch(this);
  }
}
