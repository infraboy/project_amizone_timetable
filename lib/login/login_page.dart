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
  late final Storage storage;

  @override
  void initState() {
    super.initState();
    storage = Provider.of<Storage>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Center(
              child: SizedBox(
                height: 150,
                child: Image.asset("images/scamity.png"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
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
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900],
                ),
                onPressed: () {
                  storage.setCredentials(
                      _formNumberController.text, _passwordController.text);
                  storage.tryLogin = true;
                  storage.error = null;
                  storage.setLoginStatus(true);
                },
              ),
            ),
            if (storage.error != null) ...[
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  storage.error!,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
