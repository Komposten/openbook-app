import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/community/pages/community_staff/widgets/community_administrators.dart';
import 'package:Okuna/pages/home/pages/community/pages/community_staff/widgets/community_moderators.dart';
import 'package:Okuna/pages/home/pages/community/widgets/community_card/community_card.dart';
import 'package:Okuna/pages/home/pages/community/widgets/community_cover.dart';
import 'package:Okuna/pages/home/pages/community/widgets/community_nav_bar.dart';
import 'package:Okuna/pages/home/pages/community/widgets/community_posts.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/buttons/community_floating_action_button.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityPage extends StatefulWidget {
  final Community community;

  OBCommunityPage(this.community);

  @override
  OBCommunityPageState createState() {
    return OBCommunityPageState();
  }
}

class OBCommunityPageState extends State<OBCommunityPage>
    with TickerProviderStateMixin {
  Community _community;
  OBHttpListController _httpListController;
  UserService _userService;
  LocalizationService _localizationService;

  bool _needsBootstrap;

  CancelableOperation _refreshCommunityOperation;

  @override
  void initState() {
    super.initState();
    _httpListController = OBHttpListController();
    _needsBootstrap = true;
    _community = widget.community;
  }

  void _onPostCreated(Post post) {
    _httpListController.insertListItem(post);
  }

  @override
  void dispose() {
    super.dispose();
    if (_refreshCommunityOperation != null) _refreshCommunityOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBCommunityNavBar(
          _community,
        ),
        child: OBPrimaryColorContainer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                    stream: _community.updateSubject,
                    initialData: _community,
                    builder: (BuildContext context,
                        AsyncSnapshot<Community> snapshot) {
                      Community latestCommunity = snapshot.data;

                      bool communityIsPrivate = latestCommunity.isPrivate();

                      User loggedInUser = _userService.getLoggedInUser();
                      bool userIsMember =
                          latestCommunity.isMember(loggedInUser);

                      bool userCanSeeCommunityContent =
                          !communityIsPrivate || userIsMember;

                      return userCanSeeCommunityContent
                          ? _buildCommunityContent()
                          : _buildPrivateCommunityContent();
                    }),
              )
            ],
          ),
        ));
  }

  Widget _buildCommunityContent() {
    List<Widget> stackItems = [
      OBCommunityPosts(
        httpListController: _httpListController,
        community: _community,
        httpListSecondaryRefresher: _refreshCommunity,
        prependedItems: <Widget>[
          OBCommunityCover(_community),
          OBCommunityCard(
            _community,
          )
        ],
      )
    ];

    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    User loggedInUser = openbookProvider.userService.getLoggedInUser();
    bool isMemberOfCommunity = _community.isMember(loggedInUser);

    if (isMemberOfCommunity) {
      stackItems.add(Positioned(
          bottom: 20.0,
          right: 20.0,
          child: OBCommunityNewPostButton(
            community: _community,
            onPostCreated: _onPostCreated,
          )));
    }

    return Stack(
      children: stackItems,
    );
  }

  Widget _buildPrivateCommunityContent() {
    bool communityHasInvitesEnabled = _community.invitesEnabled;
    return ListView(
      padding: EdgeInsets.all(0),
      physics: const ClampingScrollPhysics(),
      children: <Widget>[
        OBCommunityCover(_community),
        OBCommunityCard(
          _community,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: OBAlert(
            child: Column(
              children: <Widget>[
                OBText(_localizationService.trans('community__is_private'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 10,
                ),
                OBText(
                  communityHasInvitesEnabled
                      ? _localizationService.trans('community__invited_by_member')
                      :_localizationService.trans('community__invited_by_moderator'),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
        OBCommunityAdministrators(_community),
        OBCommunityModerators(_community)
      ],
    );
  }

  Future<void> _refreshCommunity() async {
    if (_refreshCommunityOperation != null) _refreshCommunityOperation.cancel();
    _refreshCommunityOperation = CancelableOperation.fromFuture(
        _userService.getCommunityWithName(_community.name));
    debugPrint(_localizationService.trans('community__refreshing'));
    var community = await _refreshCommunityOperation.value;
    _setCommunity(community);
  }

  void _setCommunity(Community community) {
    setState(() {
      _community = community;
    });
  }
}

class CommunityTabBarDelegate extends SliverPersistentHeaderDelegate {
  CommunityTabBarDelegate({
    this.controller,
    this.pageStorageKey,
    this.community,
  });

  final TabController controller;
  final Community community;
  final PageStorageKey pageStorageKey;

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var localizationService = openbookProvider.localizationService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          Color themePrimaryTextColor =
              themeValueParserService.parseColor(theme.primaryTextColor);

          return new SizedBox(
            height: kToolbarHeight,
            child: TabBar(
              controller: controller,
              key: pageStorageKey,
              indicatorColor: themePrimaryTextColor,
              labelColor: themePrimaryTextColor,
              tabs: <Widget>[
                Tab(text: localizationService.trans('community__posts')),
                Tab(text: localizationService.trans('community__about')),
              ],
            ),
          );
        });
  }

  @override
  bool shouldRebuild(covariant CommunityTabBarDelegate oldDelegate) {
    return oldDelegate.controller != controller;
  }
}

typedef void OnWantsToEditUserCommunity(User user);
