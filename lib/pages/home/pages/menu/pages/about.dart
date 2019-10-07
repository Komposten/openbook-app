import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_version/get_version.dart';
import 'package:package_info/package_info.dart';

class OBAboutPage extends StatefulWidget {
  @override
  OBAboutPageState createState() {
    return OBAboutPageState();
  }
}

class OBAboutPageState extends State<OBAboutPage> {
  String _appName = '';
  String _appVersion = '';
  String _platformVersion = '';

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    var pi = await PackageInfo.fromPlatform();
    var platformVersion = await GetVersion.platformVersion;

    if (!mounted) return;
    setState(() {
      _appName = pi.appName;
      _appVersion = pi.version;
      _platformVersion = platformVersion;
    });
  }

  Widget build(BuildContext context) {
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;

    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      navigationBar: OBThemedNavigationBar(title: _localizationService.drawer__about),
      child: OBPrimaryColorContainer(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: OBIcon(OBIcons.nativeInfo),
              title: OBText(
                _localizationService.drawer__about_version(_appName, _appVersion),
              ),
            ),
            ListTile(
              leading: OBIcon(OBIcons.nativeInfo),
              title: OBText(
                _localizationService.drawer__about_platform(_platformVersion),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
