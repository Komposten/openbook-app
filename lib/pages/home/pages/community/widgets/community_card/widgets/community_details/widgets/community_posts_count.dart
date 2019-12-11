import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/posts_count.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';

class OBCommunityPostsCount extends StatefulWidget {
  final Community community;

  OBCommunityPostsCount(this.community);

  @override
  OBCommunityPostsCountState createState() {
    return OBCommunityPostsCountState();
  }
}

class OBCommunityPostsCountState extends State<OBCommunityPostsCount> {
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  bool _requestInProgress;
  bool _hasError;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
    _hasError = false;
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    if(_needsBootstrap){
      _localizationService = openbookProvider.localizationService;
      _toastService = openbookProvider.toastService;
      _refreshCommunityPostsCount();
      _needsBootstrap = false;
    }

    return StreamBuilder(
      stream: widget.community.updateSubject,
      initialData: widget.community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;

        return _hasError
            ? _buildErrorIcon()
            : _requestInProgress
                ? _buildLoadingIcon()
                : _buildPostsCount(community);
      },
    );
  }

  Widget _buildPostsCount(Community community) {
    return OBPostsCount(
      community.postsCount,
      showZero: true,
      fontSize: 16,
    );
  }

  Widget _buildErrorIcon() {
    return const SizedBox();
  }

  Widget _buildLoadingIcon() {
    return OBProgressIndicator();
  }

  void _refreshCommunityPostsCount() async {
    _setRequestInProgress(true);
    try {
      await _userService.countPostsForCommunity(widget.community);
      print('Done!');
    } catch (e) {
      _onError(e);
    } finally {
      print('Finally');
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
