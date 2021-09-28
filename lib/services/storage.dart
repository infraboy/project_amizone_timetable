import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static final _instance = SharedPreferences.getInstance();
  StreamController<bool> loginStatus = StreamController<bool>();
  Stream<bool> get checkLoginStatus => loginStatus.stream;
  List<String> _days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

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

  Future<void> setTimeTable(Map<String, List<String>> map) async {
    final prefs = await _instance;
    for (String day in map.keys) {
      prefs.setStringList(day, map[day]!);
    }
  }

  Future<Map<String, List<List<String>>>> getTimeTable() async {
    final prefs = await _instance;
    Map<String, List<List<String>>> map = {};
    for (String day in _days) {
      List<String> dayTable = prefs.getStringList(day)!;
      List<List<String>> table = [];
      for (String i in dayTable) {
        table.add(i.split("####"));
      }
      map[day] = table;
    }
    return map;
  }
}
