import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Storage({required this.instance});
  final SharedPreferences instance;
  StreamController<bool> _loginStatus = StreamController<bool>();
  Stream<bool> get checkLoginStatus => _loginStatus.stream;
  bool tryLogin = false;
  List<String> _days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  bool getLoginStatus() {
    return instance.getBool("loginStatus") ?? false;
  }

  void setLoginStatus(bool status) {
    instance.setBool("loginStatus", status);
    _loginStatus.add(status);
  }

  void setCredentials(String formNo, String password) {
    instance.setString("formNo", formNo);
    instance.setString("password", password);
  }

  List<String> getCredentials() {
    List<String> credentials = [];
    credentials.add(instance.getString("formNo")!);
    credentials.add(instance.getString("password")!);
    return credentials;
  }

  void setTimeTable(Map<String, List<String>> map) {
    for (String day in map.keys) {
      instance.setStringList(day, map[day]!);
    }
  }

  Map<String, List<List<String>>> getTimeTable() {
    Map<String, List<List<String>>> map = {};
    for (String day in _days) {
      List<String> dayTable = instance.getStringList(day)!;
      List<List<String>> table = [];
      for (String i in dayTable) {
        table.add(i.split("####"));
      }
      map[day] = table;
    }
    return map;
  }
}
