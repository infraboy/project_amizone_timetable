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
  late final Future<Map<String, List<List<String>>>> schedule;

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
    return Scaffold(
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
              await storage.setLoginStatus(false);
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: daysOrderedList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(daysOrderedList[index]),
              selected: index == selectedDay ? true : false,
              onTap: () {
                setState(() {
                  selectedDay = index;
                });
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, List<List<String>>>>(
        future: schedule,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data![daysOrderedList[(selectedDay)]]!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: Text(snapshot
                          .data![daysOrderedList[selectedDay]]![index][0]),
                      title: Column(
                        children: [
                          Text(
                            snapshot.data![daysOrderedList[selectedDay]]![index]
                                [1],
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            snapshot.data![daysOrderedList[selectedDay]]![index]
                                [3],
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            snapshot.data![daysOrderedList[selectedDay]]![index]
                                [2],
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    )
                  ],
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
