String removeDuplicateWords(String url) {
  final parts = url.split('/');
  final uniqueParts = parts.toSet().toList();
  return uniqueParts.join('/');
}
