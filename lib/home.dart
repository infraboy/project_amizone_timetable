import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  int selectedDay = DateTime.now().weekday - 1;
  late final List<String> daysOrderedList;
  late final Storage storage;
  late final Map<String, List<List<String>>> schedule;

  @override
  void initState() {
    super.initState();
    daysOrderedList =
        days.sublist(selectedDay, days.length) + days.sublist(0, selectedDay);
    selectedDay = 0;
    storage = Provider.of<Storage>(context, listen: false);
    schedule = storage.getTimeTable();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scam Schedule"),
          actions: [
            TextButton(
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                storage.setLoginStatus(false);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.blue[900],
          ),
          child: Drawer(
            child: ListView.builder(
              itemCount: daysOrderedList.length,
              itemBuilder: (context, index) {
                bool select = index == selectedDay;
                return Column(
                  children: [
                    ListTile(
                      selectedTileColor: Colors.white,
                      tileColor: Colors.blue[900],
                      title: Text(
                        daysOrderedList[index],
                        style: TextStyle(
                          fontSize: select ? 16 : 14,
                          fontWeight:
                              select ? FontWeight.bold : FontWeight.normal,
                          color: select ? Colors.blue[900] : Colors.white,
                        ),
                      ),
                      selected: select ? true : false,
                      onTap: () {
                        setState(() {
                          selectedDay = index;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    Divider(
                      color: Colors.white,
                      height: 0,
                      thickness: 2,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: schedule[daysOrderedList[(selectedDay)]]!.length == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Image.asset("images/cat.png"),
                    ),
                    Text(
                      "No scams today, cazz",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: schedule[daysOrderedList[(selectedDay)]]!.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        isThreeLine: true,
                        leading: Text(
                          schedule[daysOrderedList[selectedDay]]![index][0],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        title: Center(
                          child: Text(
                            schedule[daysOrderedList[selectedDay]]![index][1],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            Text(
                              schedule[daysOrderedList[selectedDay]]![index][3],
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              schedule[daysOrderedList[selectedDay]]![index][2],
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 0,
                        thickness: 2,
                      )
                    ],
                  );
                },
              ),
      ),
    );
    ;
  }
}
