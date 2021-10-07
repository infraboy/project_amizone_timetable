import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _formNumberController;
  late TextEditingController _passwordController;
  late final Storage storage;

  FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    storage = Provider.of<Storage>(context, listen: false);
    final credentials = storage.getCredentials();
    _formNumberController = TextEditingController(text: credentials[0]);
    _passwordController = TextEditingController(text: credentials[1]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: storage.isLoading,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: Center(
                child: ListView(
                  padding: EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    if (snapshot.data!)
                      Center(
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: SizedBox(
                          height: 150,
                          child: Image.asset("images/scamity.png"),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _formNumberController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.blue[900]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.yellow[700]!,
                          ),
                        ),
                        labelText: "Form Number",
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _passwordFocus.requestFocus();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      focusNode: _passwordFocus,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.blue[900]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.yellow[700]!,
                          ),
                        ),
                        labelText: "Password",
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {
                        _passwordFocus.unfocus();
                        submit();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue[900],
                        ),
                        onPressed: snapshot.data! ? null : submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void submit() {
    _passwordFocus.unfocus();
    if (!storage.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Your device is currently offline, please turn on your internet connection and restart the app."),
          action: SnackBarAction(
            label: "OK",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else {
      storage.setCredentials(
          _formNumberController.text, _passwordController.text);
      storage.setLoadingStatus(true);
    }
  }
}
