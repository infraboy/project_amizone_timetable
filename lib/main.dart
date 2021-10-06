import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/loading_page.dart';
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences instance = await SharedPreferences.getInstance();
  runApp(Provider<Storage>(
    create: (_) => Storage(instance: instance),
    child: MaterialApp(
      title: "ScAmizone Schedule",
      home: LoadingPage(),
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
    ),
  ));
}
