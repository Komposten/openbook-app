import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBVideosSoundSettingPickerBottomSheet extends StatefulWidget {
  final ValueChanged<VideosSoundSetting> onTypeChanged;

  final VideosSoundSetting initialValue;

  const OBVideosSoundSettingPickerBottomSheet(
      {Key key, @required this.onTypeChanged, this.initialValue})
      : super(key: key);

  @override
  OBVideosSoundSettingPickerBottomSheetState createState() {
    return OBVideosSoundSettingPickerBottomSheetState();
  }
}

class OBVideosSoundSettingPickerBottomSheetState
    extends State<OBVideosSoundSettingPickerBottomSheet> {
  FixedExtentScrollController _cupertinoPickerController;
  List<VideosSoundSetting> allVideosSoundSettings;

  @override
  void initState() {
    super.initState();
    allVideosSoundSettings = VideosSoundSetting.values();
    _cupertinoPickerController = FixedExtentScrollController(
        initialItem: widget.initialValue != null
            ? allVideosSoundSettings.indexOf(widget.initialValue)
            : null);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    UserPreferencesService userPreferencesService =
        openbookProvider.userPreferencesService;

    Map<VideosSoundSetting, String> localizationMap =
        userPreferencesService.getVideosSoundSettingLocalizationMap();

    return OBPrimaryColorContainer(
      mainAxisSize: MainAxisSize.min,
      child: SizedBox(
        height: 216,
        child: CupertinoPicker(
          scrollController: _cupertinoPickerController,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (int index) {
            VideosSoundSetting newType = allVideosSoundSettings[index];
            widget.onTypeChanged(newType);
          },
          itemExtent: 32,
          children: allVideosSoundSettings.map((VideosSoundSetting setting) {
            return Center(
              child: OBText(localizationMap[setting]),
            );
          }).toList(),
        ),
      ),
    );
  }
}
