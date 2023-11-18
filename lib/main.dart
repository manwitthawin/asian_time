import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WorldClock(),
    );
  }
}

class WorldClock extends StatefulWidget {
  @override
  _WorldClockState createState() => _WorldClockState();
}

class _WorldClockState extends State<WorldClock> {
  List<WorldTime> locations = [
    WorldTime(url: 'Asia/Bangkok', location: 'Thailand', flag: 'Thailand.png'),
    WorldTime(url: 'Asia/Singapore', location: 'Singapore', flag: 'Singapore.png'),
    WorldTime(url: 'Asia/Jakarta', location: 'Indonesia', flag: 'Indonesia.png'),
    WorldTime(url: 'Asia/Kuala_Lumpur', location: 'Malaysia', flag: 'Malaysia.png'),
    WorldTime(url: 'Asia/Ho_Chi_Minh', location: 'Vietnam', flag: 'Vietnam.png'),
    WorldTime(url: 'Asia/Manila', location: 'Philippines', flag: 'Philippines.png'),
    WorldTime(url: 'Asia/Yangon', location: 'Myanmar', flag: 'Myanmar.png'),
    WorldTime(url: 'Asia/Phnom_Penh', location: 'Cambodia', flag: 'Cambodia.png'),
    WorldTime(url: 'Asia/Vientiane', location: 'Laos', flag: 'Laos.png'),
    WorldTime(url: 'Asia/Brunei', location: 'Brunei', flag: 'Brunei.png'),
  ];

  @override
  void initState() {
    super.initState();
    updateTime();
    for (WorldTime location in locations) {
      location.timeController.stream.listen((String? newTime) {
        setState(() {
          location.time = newTime;
        });
      });
      location.updateTimePeriodically();
    }
  }

  void updateTime() {
    for (WorldTime location in locations) {
      location.updateTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asian Clocks'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
        ),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorldTimePage(
                      location: locations[index],
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: AssetImage('assets/${locations[index].flag}'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      locations[index].location,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

  }
}

class WorldTimePage extends StatelessWidget {
  final WorldTime location;

  WorldTimePage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.location),
      ),
      body: Center(
        child: StreamBuilder<String?>(
          stream: location.timeController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Image.asset(
                    'assets/${location.flag}',
                    width: 450,
                    height: 450,
                  ),
                  Text(
                    location.location,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50.0),
                  Text(
                    '${snapshot.data}',
                    style: TextStyle(
                      fontSize: 50,
                    ),
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
class WorldTime {
  String location;
  String? time;
  String flag;
  String url;
  StreamController<String?> timeController = StreamController<String?>.broadcast();

  WorldTime({required this.url, required this.location, required this.flag});

  void updateTime() async {
    try {
      http.Response response = await http.get(
        Uri.parse('https://worldtimeapi.org/api/timezone/$url'),
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);

        String dateTimeString = data['utc_datetime'];
        String offsetString = data['utc_offset'];

        DateTime dateTime = DateTime.parse(dateTimeString);
        dateTime = dateTime.add(Duration(
          hours: int.parse(offsetString.substring(1, 3)),
          minutes: int.parse(offsetString.substring(4, 6)),
        ));

        time = DateFormat('HH:mm:ss').format(dateTime);

        timeController.add(time);
      } else {
        print('Failed to load time for $location');
      }
    } catch (e) {
      print('Error fetching time for $location: $e');
    }
  }

  void updateTimePeriodically() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      updateTime();
    });
  }
}
