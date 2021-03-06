import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/home.dart';
import 'package:project_amizone_timetable/login/login_page.dart';
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context, listen: false);
    storage.setLoginStatus(storage.getLoginStatus());
    return StreamBuilder<bool>(
      stream: storage.checkLoginStatus,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return Home();
          }
          return LoginPage();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
