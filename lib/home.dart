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
    return StreamBuilder<bool>(
        initialData: storage.loading ?? true,
        stream: storage.isLoading,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blue[900],
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
                                  fontWeight: select
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      select ? Colors.blue[900] : Colors.white,
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
                body: Column(
                  children: [
                    if (snapshot.hasData && snapshot.data!)
                      LinearProgressIndicator(),
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
                                        int.parse(classTime.substring(3, 5));
                                int classEndTime =
                                    int.parse(classTime.substring(10, 12)) *
                                            60 +
                                        int.parse(classTime.substring(13));
                                bool isSelected = time >= classStartTime &&
                                        time <= classEndTime
                                    ? true
                                    : false;
                                return Column(
                                  children: [
                                    ListTile(
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
                                      shape: isSelected
                                          ? Border.all(
                                              width: 5,
                                              color: Colors.blue[900]!,
                                            )
                                          : null,
                                    ),
                                    Divider(
                                      height: 0,
                                      thickness: 2,
                                    )
                                  ],
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
