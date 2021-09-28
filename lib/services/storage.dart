import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static final _instance = SharedPreferences.getInstance();
  StreamController<bool> loginStatus = StreamController<bool>();
  Stream<bool> get checkLoginStatus => loginStatus.stream;

  void getLoginStatus() async {
    final prefs = await _instance;
    await setLoginStatus(prefs.getBool("loginStatus") ?? false);
  }

  Future<void> setLoginStatus(bool status) async {
    final prefs = await _instance;
    prefs.setBool("loginStatus", status);
    loginStatus.add(status);
  }

  Future<void> setCredentials(String formNo, String password) async {
    final prefs = await _instance;
    prefs.setString("formNo", formNo);
    prefs.setString("password", password);
  }

  Future<List<String>> getCredentials() async {
    final prefs = await _instance;
    List<String> credentials = [];
    credentials.add(prefs.getString("formNo")!);
    credentials.add(prefs.getString("password")!);
    return credentials;
  }
}
