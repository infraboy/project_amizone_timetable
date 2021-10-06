import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Storage({required this.instance});
  final SharedPreferences instance;
  StreamController<bool> _loginStatus = StreamController<bool>();
  Stream<bool> get checkLoginStatus => _loginStatus.stream;
  StreamController<bool> _loadingController = StreamController<bool>();
  Stream<bool> get isLoading => _loadingController.stream;
  String? error;
  List<String> _days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  void setLoadingStatus(bool status) {
    _loadingController.add(status);
  }

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
    try {
      credentials.add(instance.getString("formNo")!);
      credentials.add(instance.getString("password")!);
    } catch (e) {
      credentials.add("");
      credentials.add("");
    }
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
