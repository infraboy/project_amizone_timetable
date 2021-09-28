import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _formNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context, listen: false);
    return Scaffold(
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            TextField(
              controller: _formNumberController,
              decoration: InputDecoration(
                labelText: "Form Number",
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                child: Text("Submit"),
                onPressed: () async {
                  await storage.setCredentials(
                      _formNumberController.text, _passwordController.text);
                  await storage.setLoginStatus(true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
