import 'dart:async';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/posts_stream/posts_stream.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

class OBTrendingPosts extends StatefulWidget {
  final OBTrendingPostsController controller;
  final Function(ScrollPosition) onScrollCallback;
  final double extraTopPadding;

  const OBTrendingPosts({
    this.controller,
    this.onScrollCallback,
    this.extraTopPadding = 0.0,
  });

  @override
  State<StatefulWidget> createState() {
    return OBTrendingPostsState();
  }
}

class OBTrendingPostsState extends State<OBTrendingPosts>
 with AutomaticKeepAliveClientMixin {
  UserService _userService;
  LocalizationService _localizationService;

  CancelableOperation _getTrendingPostsOperation;

  OBPostsStreamController _obPostsStreamController;

  @override
  void initState() {
    super.initState();
    _obPostsStreamController = OBPostsStreamController();
    if (widget.controller != null) widget.controller.attach(this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    if (_getTrendingPostsOperation != null) _getTrendingPostsOperation.cancel();
  }

  Future refresh() {
    return _obPostsStreamController.refreshPosts();
  }

  void scrollToTop() {
    _obPostsStreamController.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _localizationService = openbookProvider.localizationService;

    return OBPostsStream(
      streamIdentifier: 'trendingPosts',
      refresher: _postsStreamRefresher,
      onScrollLoader: _postsStreamOnScrollLoader,
      controller: _obPostsStreamController,
      onScrollCallback: widget.onScrollCallback,
      refreshIndicatorDisplacement: 110.0,
      prependedItems: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: widget.extraTopPadding),
          child: OBPrimaryAccentText(
              _localizationService.post__trending_posts_title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        )
      ],
    );
  }

  Future<List<Post>> _postsStreamRefresher() async {
    List<Post> posts = (await _userService.getTrendingPosts()).posts;

    return posts;
  }

  Future<List<Post>> _postsStreamOnScrollLoader(List<Post> posts) async {
    return [];
  }
}

class OBTrendingPostsController {
  OBTrendingPostsState _state;

  void attach(OBTrendingPostsState state) {
    _state = state;
  }

  Future<void> refresh() {
    return _state.refresh();
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}
