import 'package:hive/hive.dart';
import 'package:wallgram/models/post.dart';

class CacheService {
  final Box<Post> _postBox = Hive.box<Post>('cachedPosts');
  final Box<dynamic> _metaBox = Hive.box('cacheMeta'); // store metadata like timestamp

  static const String _cacheTimestampKey = 'postsCacheTimestamp';

  List<Post> getCachedPosts() {
    final cachedTime = _metaBox.get(_cacheTimestampKey) as DateTime?;

    if (cachedTime == null) {
      clearCache();
      return [];
    }

    final now = DateTime.now();
    final diff = now.difference(cachedTime);
    if (diff.inMinutes > 60) {
      clearCache();
      return [];
    }
    return _postBox.values.toList();
  }

  Future<void> cachePosts(List<Post> posts) async {
    await _postBox.clear(); // Clear old cache
    for (var post in posts) {
      await _postBox.put(post.id, post);
    }

    await _metaBox.put(_cacheTimestampKey, DateTime.now());
  }

  Future<void> clearCache() async {
    await _postBox.clear();
    await _metaBox.delete(_cacheTimestampKey);
  }
}
