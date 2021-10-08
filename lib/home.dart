import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_amizone_timetable/services/notification_service.dart';
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
  late Map<String, List<List<String>>> schedule;
  late final NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    daysOrderedList =
        days.sublist(selectedDay, days.length) + days.sublist(0, selectedDay);
    selectedDay = 0;
    storage = Provider.of<Storage>(context, listen: false);
    notificationService = NotificationService();
    notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: storage.loading ?? true,
        stream: storage.isLoading,
        builder: (context, snapshot) {
          schedule = storage.getTimeTable();
          return WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
                appBar: AppBar(
                  elevation: 10,
                  backgroundColor: Colors.blue[900],
                  shadowColor: Colors.blue,
                  title: Text("Scam Schedule"),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        if (!storage.isOnline) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Your device is currently offline, reload failed."),
                              action: SnackBarAction(
                                label: "OK",
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        } else {
                          storage.setLoadingStatus(true);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () async {
                        storage.setLoginStatus(false);
                      },
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: ListView.builder(
                    itemCount: daysOrderedList.length,
                    itemBuilder: (context, index) {
                      bool select = index == selectedDay;
                      return Column(
                        children: [
                          ListTile(
                            title: Center(
                              child: Text(
                                daysOrderedList[index],
                                style: TextStyle(
                                  fontSize: select ? 18 : 16,
                                  fontWeight: select
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: select
                                      ? Colors.yellow[800]
                                      : Colors.blue[900],
                                ),
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Divider(
                              color: Colors.blue[900],
                              height: 0,
                              thickness: 2,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                body: Column(
                  children: [
                    if (snapshot.hasData && snapshot.data!)
                      LinearProgressIndicator(
                        color: Colors.blue[900],
                      ),
                    Expanded(
                      child: schedule[daysOrderedList[(selectedDay)]]!.length ==
                              0
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 15),
                              itemCount:
                                  schedule[daysOrderedList[(selectedDay)]]!
                                      .length,
                              itemBuilder: (context, index) {
                                String classTime = schedule[
                                    daysOrderedList[selectedDay]]![index][0];
                                String className = schedule[
                                    daysOrderedList[selectedDay]]![index][1];
                                int time = DateTime.now().hour * 60 +
                                    DateTime.now().minute;
                                int classStartTime =
                                    int.parse(classTime.substring(0, 2)) * 60 +
                                        int.parse(classTime.substring(3, 5)) -
                                        5;
                                int classEndTime =
                                    int.parse(classTime.substring(10, 12)) *
                                            60 +
                                        int.parse(classTime.substring(13));
                                bool isSelected;
                                if (days[DateTime.now().weekday - 1] ==
                                    daysOrderedList[selectedDay]) {
                                  isSelected = time > classStartTime &&
                                          time <= classEndTime
                                      ? true
                                      : false;
                                } else {
                                  isSelected = false;
                                }
                                if (daysOrderedList[selectedDay] ==
                                    days[DateTime.now().weekday - 1]) {
                                  int time = DateTime.now().hour * 60 +
                                      DateTime.now().minute;
                                  int classStartTime =
                                      int.parse(classTime.substring(0, 2)) *
                                              60 +
                                          int.parse(classTime.substring(3, 5)) -
                                          5;
                                  int classEndTime =
                                      int.parse(classTime.substring(10, 12)) *
                                              60 +
                                          int.parse(classTime.substring(13));
                                  if (time < classStartTime)
                                    notificationService.addNotification(
                                        classTime, className);
                                  else if (time < classEndTime)
                                    notificationService.addNotification(
                                        classTime, className, true);
                                }
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 15),
                                  child: Card(
                                    elevation: 10,
                                    shadowColor:
                                        isSelected ? Colors.yellowAccent : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: isSelected
                                          ? BorderSide(
                                              width: 4.0,
                                              color: Colors.yellow[700]!,
                                            )
                                          : BorderSide.none,
                                    ),
                                    child: ListTile(
                                      isThreeLine: true,
                                      leading: Text(
                                        classTime,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      title: Center(
                                        child: Text(
                                          className,
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
                                            schedule[daysOrderedList[
                                                selectedDay]]![index][3],
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            schedule[daysOrderedList[
                                                selectedDay]]![index][2],
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                )),
          );
        });
  }
}
