import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() {
    _initializeDataFromPrefs();
  }
  late UserModel _userData;
  bool _isFirstLaunch = true;
  bool _isNewOpen = true;

  UserModel get userData => _userData;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isNewOpen => _isNewOpen;

  String currentPlaylistText = "";
  bool isButtonLoading = false;

  void setButtonLoading(bool) {
    isButtonLoading = bool;
    notifyListeners();
  }

  void setPlaylistText(String text) {
    currentPlaylistText = text;
    notifyListeners();
  }

  setIsNewOpen(bool value) {
    _isNewOpen = value;
  }

  setFirstLaunch(bool data) async {
    _isFirstLaunch = data;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', data);
  }

  setUserData(UserModel user) {
    _userData = user;
    notifyListeners();
  }

  Future<void> _initializeDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('firstLaunch');

    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
    }

    notifyListeners();
  }
}
