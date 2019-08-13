import 'dart:io';
import 'dart:ui';

import 'package:Okuna/models/theme.dart';
import 'package:Okuna/services/storage.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pigment/pigment.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class ThemeService {
  UtilsService _utilsService;

  Stream<OBTheme> get themeChange => _themeChangeSubject.stream;
  final _themeChangeSubject = ReplaySubject<OBTheme>(maxSize: 1);

  Random random = new Random();

  OBTheme _activeTheme;
  int _selectedThemeId;

  OBStorage _storage;

  static const _spaceRandomId = -2;
  static const _lightRandomId = -1;

  List<OBTheme> _themes = [
    OBTheme(
        id: 1,
        name: 'White Gold',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        primaryAccentColor: '#e9a039,#f0c569',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-white-gold.png'),
    OBTheme(
        id: 2,
        name: 'Dark Gold',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#000000',
        primaryAccentColor: '#e9a039,#f0c569',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-dark-gold.png'),
    OBTheme(
        id: 3,
        name: 'Light',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        primaryAccentColor: '#ffdd00,#f93476',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview: 'assets/images/theme-previews/theme-preview-white.png'),
    OBTheme(
        id: 4,
        name: 'Dark',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#000000',
        primaryAccentColor: '#ffdd00,#f93476',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview: 'assets/images/theme-previews/theme-preview-dark.png'),
    OBTheme(
        id: 5,
        name: 'Light Blue',
        primaryAccentColor: '#045DE9, #7bd1e0',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-blue.png'),
    OBTheme(
        id: 6,
        name: 'Space Blue',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#045DE9, #7bd1e0',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-blue.png'),
    OBTheme(
        id: 7,
        name: 'Light Rose',
        primaryAccentColor: '#D4418E, #ff84af',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-rose.png'),
    OBTheme(
        id: 8,
        name: 'Space Rose',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#D4418E, #ff84af',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-rose.png'),
    OBTheme(
        id: 9,
        name: 'Light Royale',
        primaryAccentColor: '#5F0A87, #B621FE',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-royale.png'),
    OBTheme(
        id: 10,
        name: 'Space Royale',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#5F0A87, #B621FE',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-royale.png'),
    OBTheme(
        id: 11,
        name: 'Light Cinnabar',
        primaryAccentColor: '#9F9F9F, #B0B0B0',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-cinnabar.png'),
    OBTheme(
        id: 12,
        name: 'Space Cinnabar',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#A71D31, #F53844',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-cinnabar.png'),
    OBTheme(
        id: _lightRandomId,
        name: 'Light Random Preset',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        primaryAccentColor: '#9F9F9F, #B0B0B0',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-colorful.png'),
    OBTheme(
        id: _spaceRandomId,
        name: 'Space Random Preset',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#9F9F9F, #B0B0B0',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-colorful.png'),
  ];

  ThemeService() {
    _setActiveTheme(_themes[2]);
  }

  void setStorageService(StorageService storageService) {
    _storage = storageService.getSystemPreferencesStorage(namespace: 'theme');
    this._bootstrap();
  }

  void setUtilsService(UtilsService utilsService) {
    _utilsService = utilsService;
  }

  void setActiveTheme(OBTheme theme) {
    _setActiveTheme(theme);
    _storeActiveThemeId(theme.id);
  }

  void _bootstrap() async {
    int activeThemeId = await _getStoredActiveThemeId();

    if (activeThemeId != null) {
      OBTheme activeTheme = await _getThemeWithId(activeThemeId);
      _setActiveTheme(activeTheme);
    }
  }

  void _setActiveTheme(OBTheme theme) {
    _selectedThemeId = theme.id;

    if (theme.id < 0) {
      theme = _getRandomTheme(theme.id == _spaceRandomId);
    }

    _activeTheme = theme;
    _themeChangeSubject.add(theme);
  }

  OBTheme _getRandomTheme(bool space) {
    Random random = new Random();
    int steps = random.nextInt(_themes.length)+1;

    int index = 0;
    int counter = 0;
    OBTheme theme;

    while (counter < steps) {
      theme = _themes[index % _themes.length];
      var isSpaceTheme = _isSpaceTheme(theme);
      if (theme.id >= 0 && ((space && isSpaceTheme) || (!space && !isSpaceTheme))) {
        counter++;
      }

      index++;
    }

    return theme;
  }

  bool _isSpaceTheme(OBTheme theme) {
    return int.parse(theme.primaryColor.substring(1), radix: 16) < 0x7f7f7f;
  }

  void _storeActiveThemeId(int themeId) {
    if (_storage != null) _storage.set('activeThemeId', themeId.toString());
  }

  Future<OBTheme> _getThemeWithId(int id) async {
    return _themes.firstWhere((OBTheme theme) {
      return theme.id == id;
    });
  }

  Future<int> _getStoredActiveThemeId() async {
    String activeThemeId = await _storage.get('activeThemeId');
    return activeThemeId != null ? int.parse(activeThemeId) : null;
  }

  OBTheme getActiveTheme() {
    return _activeTheme;
  }

  bool isActiveTheme(OBTheme theme) {
    return theme.id == this.getActiveTheme().id;
  }

  bool isSelectedTheme(OBTheme theme) {
    return theme.id == _selectedThemeId;
  }

  List<OBTheme> getCuratedThemes() {
    return _themes.toList();
  }

  String generateRandomHexColor() {
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while (length-- > 0) hex += chars[(random.nextInt(16)) | 0];
    return hex;
  }
}
