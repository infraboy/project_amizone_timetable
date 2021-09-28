import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as wv;
import 'package:project_amizone_timetable/home.dart';
import 'package:html/dom.dart' as dom;
import 'package:project_amizone_timetable/services/storage.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late wv.InAppWebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isOnline(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _children(),
                ),
              ),
            );
          }
          return Home();
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
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

  List<Widget> _children() {
    return [
      Expanded(
        flex: 1,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      Expanded(
        flex: 10,
        child: Visibility(
          maintainState: true,
          visible: true,
          child: wv.InAppWebView(
            initialUrlRequest:
                wv.URLRequest(url: Uri.parse("https://s.amizone.net/")),
            onWebViewCreated: (wv.InAppWebViewController controller) {
              _controller = controller;
            },
            onLoadStop: (controller, url) async {
              await readJS();
            },
          ),
        ),
      ),
    ];
  }

  Future<void> readJS() async {
    final storage = Provider.of<Storage>(context, listen: false);
    List<String> credentials = await storage.getCredentials();
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
        } catch (e) {}
      }
      print(timeTable);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Home(),
      ));
    }
    // TODO add login validation somehow
  }
}
