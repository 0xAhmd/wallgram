import 'package:hive/hive.dart';
import 'package:wallgram/models/post.dart';

class CacheService {
  final Box<Post> _postBox = Hive.box<Post>('cachedPosts');
  final Box<dynamic> _metaBox = Hive.box('cacheMeta'); // store metadata like timestamp

  static const String _cacheTimestampKey = 'postsCacheTimestamp';

  List<Post> getCachedPosts() {
    final cachedTime = _metaBox.get(_cacheTimestampKey) as DateTime?;

    if (cachedTime == null) {
      print('[CacheService] No cache timestamp found. Clearing cache and returning empty list.');
      clearCache();
      return [];
    }

    final now = DateTime.now();
    final diff = now.difference(cachedTime);

    print('[CacheService] Cache timestamp: $cachedTime');
    print('[CacheService] Current time: $now');
    print('[CacheService] Cache age in minutes: ${diff.inMinutes}');

    if (diff.inMinutes > 60) {
      print('[CacheService] Cache expired (older than 60 minutes). Clearing cache.');
      clearCache();
      return [];
    }

    print('[CacheService] Cache is valid. Returning ${_postBox.length} posts from cache.');
    return _postBox.values.toList();
  }

  Future<void> cachePosts(List<Post> posts) async {
    print('[CacheService] Caching ${posts.length} posts...');
    await _postBox.clear(); // Clear old cache
    for (var post in posts) {
      await _postBox.put(post.id, post);
    }

    await _metaBox.put(_cacheTimestampKey, DateTime.now());
    print('[CacheService] Cache timestamp updated to ${DateTime.now()}');
  }

  Future<void> clearCache() async {
    print('[CacheService] Clearing all cached posts and cache timestamp.');
    await _postBox.clear();
    await _metaBox.delete(_cacheTimestampKey);
  }
}
