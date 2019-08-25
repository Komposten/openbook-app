import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/services/storage.dart';

class UserPreferencesService {
  static const keyAskToConfirmOpen = 'askToConfirmOpen';
  static const keyAskToConfirmExceptions = 'askToConfirmExceptions';

  OBStorage _storage;
  static const postCommentsSortTypeStorageKey = 'postCommentsSortType';
  Future _getPostCommentsSortTypeCache;

  void setStorageService(StorageService storageService) {
    _storage = storageService.getSystemPreferencesStorage(
        namespace: 'userPreferences');
  }

  Future setPostCommentsSortType(PostCommentsSortType type) {
    _getPostCommentsSortTypeCache = null;
    String rawType = PostComment.convertPostCommentSortTypeToString(type);
    return _storage.set(postCommentsSortTypeStorageKey, rawType);
  }

  Future<PostCommentsSortType> getPostCommentsSortType() async {
    if (_getPostCommentsSortTypeCache != null)
      return _getPostCommentsSortTypeCache;
    _getPostCommentsSortTypeCache = _getPostCommentsSortType();
    return _getPostCommentsSortTypeCache;
  }

  Future<PostCommentsSortType> _getPostCommentsSortType() async {
    String rawType = await _storage.get(postCommentsSortTypeStorageKey);
    if (rawType == null) {
      PostCommentsSortType defaultSortType = _getDefaultPostCommentsSortType();
      await setPostCommentsSortType(defaultSortType);
      return defaultSortType;
    }
    return PostComment.parsePostCommentSortType(rawType);
  }

  PostCommentsSortType _getDefaultPostCommentsSortType() {
    return PostCommentsSortType.asc;
  }

  Future setAskToConfirmOpenUrl(bool ask, {String host}) async {
    Future status = Future.value(true);
    if (host == null) {
      status = _storage?.set(keyAskToConfirmOpen, ask.toString());
    } else {
      host = host.toLowerCase();
      List<String> exceptions =
          await _storage?.getList(keyAskToConfirmExceptions) ?? <String>[];

      var hasException = exceptions.contains(host);

      if (!hasException && !ask) {
        exceptions.add(host);
        status = _storage?.setList(keyAskToConfirmExceptions, exceptions);
      } else if (hasException && ask) {
        exceptions.remove(host);
        status = _storage?.setList(keyAskToConfirmExceptions, exceptions);
      }
    }

    return status;
  }

  Future<bool> getAskToConfirmOpenUrl({String host}) async {
    String ask = await _storage?.get(keyAskToConfirmOpen);
    bool shouldAsk = true;

    if (ask != null && ask.toLowerCase() == "false") {
      shouldAsk = false;
    } else if (host != null) {
      List<String> exceptions =
          await _storage?.getList(keyAskToConfirmExceptions);

      if (exceptions != null && exceptions.contains(host)) {
        shouldAsk = false;
      }
    }

    return shouldAsk;
  }

  Future<List<String>> getTrustedDomains() async {
    return _storage?.getList(keyAskToConfirmExceptions);
  }

  Future clear() {
    return _storage.clear();
  }
}
