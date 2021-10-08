import 'dart:async';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as wv;
import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/landing_page.dart';
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';
import 'package:html/dom.dart' as dom;

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final Storage storage;
  String? error;
  late Timer timer;
  late wv.InAppWebViewController _controller;

  @override
  void dispose() {
    timer.cancel();
    _controller.clearCache();
    _controller.reload();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    storage = Provider.of<Storage>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback(
      (timeStamp) => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LandingPage(),
          transitionDuration: Duration(seconds: 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isOnline(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return StreamBuilder<bool>(
              initialData: storage.getLoginStatus() ? true : false,
              stream: storage.isLoading,
              builder: (context, snapshot) {
                if (snapshot.data!) {
                  return _login();
                } else {
                  return Container();
                }
              },
            );
          } else {
            storage.isOnline = false;
            storage.setLoadingStatus(false);
          }
        }
        return Container();
      },
    );
  }

  Widget _login() {
    timer = Timer(Duration(minutes: 1), () {
      storage.setLoadingStatus(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Amizone took more time than expected, plz try again after some time."),
          action: SnackBarAction(
            label: "OK",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
    return Scaffold(
      body: wv.InAppWebView(
        initialUrlRequest:
            wv.URLRequest(url: Uri.parse("https://s.amizone.net/")),
        onWebViewCreated: (wv.InAppWebViewController controller) {
          _controller = controller;
        },
        onLoadStop: (controller, url) async {
          await readJS();
        },
      ),
    );
  }

  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> readJS() async {
    List<String> credentials = storage.getCredentials();
    await _controller.evaluateJavascript(source: """
            document.querySelector("#loginform > div:nth-child(2) > input.input100").value = "${credentials[0]}";
            document.querySelector("#loginform > div:nth-child(3) > input").value = "${credentials[1]}";
            document.querySelector("#loginform > div.container-login100-form-btn > button").click();                      
            """);
    final uri = await _controller.getUrl();
    if (uri == Uri.parse("https://s.amizone.net/Home")) {
      String check =
          await _controller.evaluateJavascript(source: """              
      document.getElementsByClassName("tab-content")[0].getElementsByClassName("tab-pane")[0].textContent;	    
      """);
      await _controller.evaluateJavascript(source: """                    
	    document.querySelector("#M10").click();	      
      """);
      while (true) {
        String value =
            await _controller.evaluateJavascript(source: """              
      document.getElementsByClassName("tab-content")[0].getElementsByClassName("tab-pane")[0].textContent;	    
      """);
        if (value != check) break;
        await Future.delayed(Duration(
          milliseconds: 200,
        ));
      }
      String html = await _controller.evaluateJavascript(source: """
              document.getElementsByTagName("html")[0].outerHTML;
            """);
      dom.Document document = dom.Document.html(html);
      final elements = document
          .getElementsByClassName("tab-content")[0]
          .getElementsByClassName("tab-pane");

      Map<String, List<String>> timeTable = {};
      for (var element in elements) {
        timeTable[element.id] = [];
        try {
          for (var e
              in element.getElementsByClassName("thumbnail timetable-box")) {
            List<String> period = e.text.split("\n");
            int n = period.length;
            for (int i = 0; i < n; i++) {
              period[i] = period[i].trim();
            }
            timeTable[element.id]!.add(period.sublist(1, n - 1).join("####"));
          }
          if (element.id == "Monday" ||
              element.id == "Thursday" ||
              element.id == "Friday") {
            int pos = 0;
            for (int i = 0; i < timeTable[element.id]!.length; i++) {
              if (int.parse(timeTable[element.id]![i].substring(0, 2)) < 13) {
                pos = i + 1;
              }
            }
            timeTable[element.id]!.insert(
                pos, "13:50  to 14:45####DTT####Dhritiman Mukherjee####402");
          }
        } catch (e) {}
      }
      storage.setTimeTable(timeTable);
      if (!storage.getLoginStatus()) storage.setLoginStatus(true);
      storage.setLoadingStatus(false);
      timer.cancel();
    }
    try {
      String validate = await _controller.evaluateJavascript(
          source:
              """document.querySelector("#loginform > div.text-danger").textContent""");
      if (validate.isNotEmpty) {
        timer.cancel();
        storage.setLoadingStatus(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validate),
            action: SnackBarAction(
              label: "OK",
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        storage.setLoadingStatus(false);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
