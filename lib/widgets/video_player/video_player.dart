import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/widgets/video_player/widgets/chewie/chewie_player.dart';
import 'package:Okuna/widgets/video_player/widgets/video_player_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:video_player/video_player.dart';

import '../progress_indicator.dart';

var rng = new Random();

class OBVideoPlayer extends StatefulWidget {
  final File video;
  final String videoUrl;
  final String thumbnailUrl;
  final Key visibilityKey;
  final ChewieController chewieController;
  final VideoPlayerController videoPlayerController;
  final bool isInDialog;
  final bool autoPlay;
  final OBVideoPlayerController controller;
  final double height;
  final double width;
  final bool isConstrained;

  const OBVideoPlayer(
      {Key key,
      this.video,
      this.videoUrl,
      this.thumbnailUrl,
      this.chewieController,
      this.videoPlayerController,
      this.isInDialog = false,
      this.autoPlay = false,
      this.visibilityKey,
      this.height,
      this.width,
      this.controller,
      this.isConstrained})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBVideoPlayerState();
  }
}

class OBVideoPlayerState extends State<OBVideoPlayer> {
  VideoPlayerController _playerController;
  ChewieController _chewieController;
  OBVideoPlayerControlsController _obVideoPlayerControlsController;
  UserPreferencesService _userPreferencesService;

  Future _initializeVideoPlayerFuture;

  bool _needsChewieBootstrap;

  bool _isVideoHandover;
  bool _hasVideoOpenedInDialog;
  bool _isPausedDueToInvisibility;
  bool _isPausedByUser;
  bool _needsBootstrap;

  Key _visibilityKey;

  StreamSubscription _videosSoundSettingsChangeSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller.attach(this);
    _obVideoPlayerControlsController = OBVideoPlayerControlsController();
    _hasVideoOpenedInDialog = widget.isInDialog ?? false;
    _needsChewieBootstrap = true;
    _isPausedDueToInvisibility = false;
    _isPausedByUser = false;
    _needsBootstrap = true;

    _isVideoHandover =
        widget.videoPlayerController != null && widget.chewieController != null;

    String visibilityKeyFallback;
    if (widget.videoUrl != null) {
      _playerController = VideoPlayerController.network(widget.videoUrl);
      visibilityKeyFallback = widget.videoUrl;
    } else if (widget.video != null) {
      _playerController = VideoPlayerController.file(widget.video);
      visibilityKeyFallback = widget.video.path;
    } else if (widget.videoPlayerController != null) {
      _playerController = widget.videoPlayerController;
      visibilityKeyFallback = widget.videoPlayerController.dataSource;
    } else {
      throw Exception('Video dialog requires video or videoUrl.');
    }

    visibilityKeyFallback += '-${rng.nextInt(1000)}';

    _playerController.setVolume(0);

    _visibilityKey = widget.visibilityKey != null
        ? widget.visibilityKey
        : Key(visibilityKeyFallback);

    _initializeVideo();
  }

  @override
  void dispose() {
    super.dispose();
    if (!_isVideoHandover && mounted && !_hasVideoOpenedInDialog) {
      _videosSoundSettingsChangeSubscription?.cancel();
      if (_playerController != null) _playerController.dispose();
      if (_chewieController != null) _chewieController.dispose();
    }
  }

  void _onUserPreferencesVideosSoundSettingsChange(
      VideosSoundSetting newVideosSoundSettings) {
    if (newVideosSoundSettings == VideosSoundSetting.enabled) {
      _playerController.setVolume(100);
    } else {
      _playerController.setVolume(0);
    }
  }

  void _initializeVideo() {
    if(_isVideoHandover){
      debugLog('Not initializing video player as it is handover');
      _initializeVideoPlayerFuture = Future.value();
    } else{
      debugLog('Initializing video player');
      _initializeVideoPlayerFuture =
      _playerController.initialize();
    }
  }

  void _bootstrap() async {
    VideosSoundSetting videosSoundSetting =
        await _userPreferencesService.getVideosSoundSetting();
    _onUserPreferencesVideosSoundSettingsChange(videosSoundSetting);

    _videosSoundSettingsChangeSubscription = _userPreferencesService
        .videosSoundSettingChange
        .listen(_onUserPreferencesVideosSoundSettingsChange);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userPreferencesService = openbookProvider.userPreferencesService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_needsChewieBootstrap) {
            _chewieController = _getChewieController();
            _needsChewieBootstrap = false;
          }

          return VisibilityDetector(
            key: _visibilityKey,
            onVisibilityChanged: _onVisibilityChanged,
            child: Chewie(
                height: widget.height,
                width: widget.width,
                controller: _chewieController,
                isConstrained: widget.isConstrained),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return Stack(
            children: <Widget>[
              widget.thumbnailUrl != null
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AdvancedNetworkImage(widget.thumbnailUrl,
                            useDiskCache: true),
                      )),
                    )
                  : const SizedBox(),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Center(
                    child: OBProgressIndicator(
                  color: Colors.white,
                )),
              )
            ],
          );
        }
      },
    );
  }

  void _onControlsPlay(Function originalPlayFunction) {
    debugLog('User is playing');
    _isPausedByUser = false;
    originalPlayFunction();
  }

  void _onControlsPause(Function originalPauseFunction) {
    debugLog('User is pausing');
    _isPausedByUser = true;
    originalPauseFunction();
  }

  void _onControlsMute(Function originalMuteFunction) {
    _userPreferencesService.setVideosSoundSetting(VideosSoundSetting.disabled);
  }

  void _onControlsUnmute(Function originalUnmuteFunction) {
    _userPreferencesService.setVideosSoundSetting(VideosSoundSetting.enabled);
  }

  void _onExpandCollapse(Function originalExpandFunction) async {
    if (_hasVideoOpenedInDialog) {
      _obVideoPlayerControlsController.pop();
      _hasVideoOpenedInDialog = false;
      return;
    }

    _hasVideoOpenedInDialog = true;
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    await openbookProvider.dialogService.showVideo(
        context: context,
        video: widget.video,
        videoUrl: widget.videoUrl,
        videoPlayerController: _playerController,
        chewieController: _chewieController);
    _hasVideoOpenedInDialog = false;
  }

  // Return back to config

  ChewieController _getChewieController() {
    if (widget.chewieController != null) return widget.chewieController;
    double aspectRatio = _playerController.value.aspectRatio;
    return ChewieController(
        autoInitialize: false,
        videoPlayerController: _playerController,
        showControlsOnInitialize: false,
        customControls: OBVideoPlayerControls(
          controller: _obVideoPlayerControlsController,
          onExpandCollapse: _onExpandCollapse,
          onPause: _onControlsPause,
          onPlay: _onControlsPlay,
          onMute: _onControlsMute,
          onUnmute: _onControlsUnmute,
        ),
        aspectRatio: aspectRatio,
        autoPlay: widget.autoPlay,
        looping: true);
  }

  void _onVisibilityChanged(VisibilityInfo visibilityInfo) {
    if (_hasVideoOpenedInDialog) return;
    bool isVisible = visibilityInfo.visibleFraction != 0;

    debugLog(
        'isVisible: ${isVisible.toString()} with fraction ${visibilityInfo.visibleFraction}');

    if (!isVisible && _playerController.value.isPlaying && mounted) {
      debugLog('Its not visible and the video is playing. Now pausing. .');
      _isPausedDueToInvisibility = true;
      _playerController.pause();
    }
  }

  void _pause() {
    _playerController.pause();
    _isPausedByUser = false;
    _isPausedDueToInvisibility = false;
  }

  void _play() {
    _isPausedDueToInvisibility = false;
    _isPausedByUser = false;
    _playerController.play();
  }

  void debugLog(String log) {
    //ValueKey<String> key = _visibilityKey;
    //debugPrint('OBVideoPlayer:${key.value}: $log');
  }
}

class OBVideoPlayerController {
  OBVideoPlayerState _state;

  void attach(state) {
    _state = state;
  }

  void pause() {
    if (!isReady()) {
      debugLog('State is not ready. Wont pause.');
      return;
    }
    _state._pause();
  }

  void play() {
    if (!isReady()) {
      debugLog('State is not ready. Wont play.');
      return;
    }
    _state._play();
  }

  bool isPlaying() {
    if (!isReady()) return false;

    return _state._playerController.value.isPlaying;
  }

  bool isReady() {
    return _state != null && _state.mounted && _state._playerController != null;
  }

  bool hasVideoOpenedInDialog() {
    if (!isReady()) return false;

    return _state._hasVideoOpenedInDialog;
  }

  bool isPausedByUser() {
    if (!isReady()) return false;
    return _state._isPausedByUser;
  }

  bool isPausedDueToInvisibility() {
    if (!isReady()) return false;
    return _state._isPausedDueToInvisibility;
  }

  String getIdentifier() {
    if (!isReady()) {
      debugLog('State is not ready. Can not get identifier.');
      return 'unknown';
    }

    return _state._playerController.dataSource;
  }

  void debugLog(String log) {
    debugPrint('OBVideoPlayerController: $log');
  }
}
