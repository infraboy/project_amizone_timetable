import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/landing_page.dart';
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Provider<Storage>(
    create: (_) => Storage(),
    child: MaterialApp(
      title: "Scam Schedule",
      home: LandingPage(),
    ),
  ));
}
