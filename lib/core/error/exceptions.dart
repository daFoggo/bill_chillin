// Firebase, API, Network,...
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

// Isar, SharedPreferences,...
class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}
