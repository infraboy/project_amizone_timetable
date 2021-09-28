import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Scam Schedule"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Logout"),
          onPressed: () async {
            await storage.setLoginStatus(false);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
