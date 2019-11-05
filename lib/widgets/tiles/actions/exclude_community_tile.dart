import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class OBExcludeCommunityTile extends StatefulWidget {
  final Post post;
  final VoidCallback onExcludedPostCommunity;
  final VoidCallback onUndoExcludedPostCommunity;

  const OBExcludeCommunityTile({
    Key key,
    @required this.post,
    this.onExcludedPostCommunity,
    this.onUndoExcludedPostCommunity,
  }) : super(key: key);

  @override
  OBExcludeCommunityTileState createState() {
    return OBExcludeCommunityTileState();
  }
}

class OBExcludeCommunityTileState extends State<OBExcludeCommunityTile> {
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  CancelableOperation _excludeCommunityOperation;
  CancelableOperation _undoExcludeCommunityOperation;

  bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data;

        bool isExcluded = post.isFromExcludedCommunity;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(isExcluded ? OBIcons.undoExcludePostCommunity : OBIcons.excludePostCommunity),
          title: OBText(isExcluded
              ? _localizationService.post__undo_exclude_post_community
              : _localizationService.post__exclude_post_community),
          onTap: isExcluded ? _undoExcludePostCommunity : _excludePostCommunity,
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_excludeCommunityOperation != null) _excludeCommunityOperation.cancel();
    if (_undoExcludeCommunityOperation != null) _undoExcludeCommunityOperation.cancel();
  }

  void _excludePostCommunity() async {
    if (_excludeCommunityOperation != null) return;
    _setRequestInProgress(true);
    try {
      _excludeCommunityOperation = CancelableOperation.fromFuture(_userService.excludePostCommunityFromTopPosts(widget.post.community));
      String message = await _excludeCommunityOperation.value;
      if (widget.onExcludedPostCommunity != null) widget.onExcludedPostCommunity();
      widget.post.updateIsFromExcludedCommunity(true);
      _toastService.success(message: message, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _excludeCommunityOperation = null;
      _setRequestInProgress(false);
    }
  }

  void _undoExcludePostCommunity() async {
    if (_undoExcludeCommunityOperation != null) return;
    _setRequestInProgress(true);
    try {
      _undoExcludeCommunityOperation = CancelableOperation.fromFuture(_userService.undoExcludePostCommunityFromTopPosts(widget.post.community));
      String message = await _undoExcludeCommunityOperation.value;
      if (widget.onUndoExcludedPostCommunity != null) widget.onUndoExcludedPostCommunity();
      _toastService.success(message: message, context: context);
      widget.post.updateIsFromExcludedCommunity(false);
    } catch (e) {
      _onError(e);
    } finally {
      _undoExcludeCommunityOperation = null;
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
