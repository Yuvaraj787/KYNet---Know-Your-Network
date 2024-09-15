import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speed_checker_plugin/speed_checker_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

// experimental
import 'package:speed_test_dart/classes/server.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const int bgColor = 0xFFE5E5E5;

  // Status and connection details
  String _status = '';
  String _server = '';
  String _connType = '';
  String _ip = '';
  String _isp = '';

  // Location details
  String lat = '';
  String long = '';

  // Date and time details
  String date = ''; // dd-mm-yyyy
  String time = ''; // hh:mm
  String day = ''; // Monday to Sunday
  String dayType = ''; // Weekday or Weekend
  String session =
      ''; // Early morning, morning, afternoon, evening, night, or midnight

  // Speed test details
  int _ping = 0;
  int _percent = 0;
  double _curSpeed = 0;
  double _downSpeed = 0;
  double _upSpeed = 0;

  // Environment details
  String _envType = 'Crowded';
  String _locName = '';
  String _env = 'Indoor';
  int _floor = 0;
  String temp = '';
  String mobility = 'Not Detected';
  String velocity = '0.0';
  String climate = '';

  final TextEditingController _locNameCtrl = TextEditingController();
  final SpeedCheckerPlugin _plugin = SpeedCheckerPlugin();
  late StreamSubscription<SpeedTestResult> _sub;

  void setTimeDetails() {
    DateTime now = DateTime.now();
    date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    day = days[now.weekday % 7];
    dayType =
        (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)
            ? 'Weekend'
            : 'Weekday';
    int hour = now.hour;
    session = (hour >= 0 && hour < 6)
        ? 'Midnight'
        : (hour >= 6 && hour < 9)
            ? 'Early Morning'
            : (hour >= 9 && hour < 12)
                ? 'Morning'
                : (hour >= 12 && hour < 16)
                    ? 'Afternoon'
                    : (hour >= 16 && hour < 20)
                        ? 'Evening'
                        : 'Night';
  }

  @override
  void dispose() {
    _plugin.dispose();
    _locNameCtrl.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      long = pos.longitude.toString();
      lat = pos.latitude.toString();
    });
    await _getWeather();
  }

  Future<void> _getWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=cd908d976e0a1eed6e522b5af2bf5ab7&units=metric';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      setState(() {
        temp = data['main']['temp'].toString() ?? 'Unknown weather';
        climate = data['weather'][0]['description'] ?? 'Unknown climate';
      });
    } else {
      setState(() {
        temp = "Error in finding temperature";
        climate = "Error in finding climate";
      });
    }
  }

  Future<void> getConnectionDetails() async {
    final res = await http.get(Uri.parse('http://ip-api.com/json'));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var isp1 = data['isp'].contains("Jio")
          ? "Jio"
          : data['isp'].contains("Airtel")
              ? "Airtel"
              : data['isp'].contains("Vodafone")
                  ? "Vodafone"
                  : data['isp'].contains("BSNL")
                      ? "BSNL"
                      : "Other";
      setState(() {
        _ip = data['query'];
        _isp = isp1;
      });
    } else {
      setState(() {
        _ip = 'Unknown';
        _isp = 'Unknown';
      });
    }
  }

  void detectMovement() {
    Geolocator.getPositionStream().listen((position) {
      double speedMps = position.speed; // This is your speed
      String category = '';
      // Categorize speed based on common thresholds
      if (speedMps < 0.2) {
        category = "No movement";
      } else if (speedMps < 0.7) {
        category = "Slow Walking";
      } else if (speedMps < 1.4) {
        category = "Walking";
      } else if (speedMps < 3.0) {
        category = "Running";
      } else {
        category = "Moving in Vehicle";
      }

      setState(() {
        mobility = category;
        velocity = speedMps.toStringAsFixed(2);
      });

      // Do something with the category (e.g., update UI, log data)
      print("Category: $category");
    });
  }

// experimental

  final SpeedTestDart _tester = SpeedTestDart();
  List<Server> _bestServersList = [];

  Future<void> initializeBestServers() async {
    final settings = await _tester.getSettings();
    final servers = settings.servers;
    final listServers = await _tester.getBestServers(servers: servers);
    setState(() {
        _bestServersList = listServers;
    });
  }

    Future<double> getDownloadSpeed() async {
      print("called function");
    if (_bestServersList.isEmpty) {
      await initializeBestServers();
    }

    try {
      print("checking speed");
      final downloadRate = await _tester.testDownloadSpeed(
        servers: _bestServersList,
      );
      print("Download speed");
      print(downloadRate);
      setState(() {
        _downSpeed = downloadRate;
      });

      return downloadRate; // returns speed in Mbps
    } catch (e) {
      print('Error getting download speed: $e');
      return 0.0; // Return 0 or some default value in case of error
    }
  }

  void getSpeedStats() {
    getDownloadSpeed();
    detectMovement();
    getLocation();
    setTimeDetails();
    getConnectionDetails();
  }

  void stopTest() {
    _plugin.stopTest();
    _sub = _plugin.speedTestResultStream.listen((result) {
      setState(() {
        _status = "Speed test stopped";
        _ping = 0;
        _percent = 0;
        _curSpeed = 0;
        _downSpeed = 0;
        _upSpeed = 0;
        _server = '';
        _connType = '';
        _ip = '';
        _isp = '';
      });
    }, onDone: () {
      _sub.cancel();
    });
  }

  Padding tableCellPadding(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('KYNet')),
        body: Container(
          color: const Color(bgColor).withOpacity(0.5),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Environment Type',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _envType,
                          items:
                              <String>['Crowded', 'Free'].map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _envType = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Text('Location Name',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: _locNameCtrl,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          onChanged: (value) {
                            setState(() {
                              _locName = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Text('Environment',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _env,
                          items:
                              <String>['Indoor', 'Outdoor'].map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _env = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Text('Floor',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButton<int>(
                          value: _floor,
                          items: List.generate(5, (index) => index)
                              .map((int value) {
                            return DropdownMenuItem<int>(
                                value: value, child: Text(value.toString()));
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _floor = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Speed test results'.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Table(
                      border: TableBorder.all(color: Colors.black, width: 1),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth()
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(children: [
                          tableCellPadding('Mobility Status:'),
                          tableCellPadding('$mobility')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Movement Spped:'),
                          tableCellPadding('$velocity m/s')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Ping:'),
                          tableCellPadding('$_ping ms')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Download speed:'),
                          tableCellPadding(
                              '${_downSpeed.toStringAsFixed(2)} Mbps')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Upload speed:'),
                          tableCellPadding(
                              '${_upSpeed.toStringAsFixed(2)} Mbps')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Connection Type:'),
                          tableCellPadding('$_connType')
                        ]),
                        TableRow(children: [
                          tableCellPadding('User ISP:'),
                          tableCellPadding('$_isp')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Latitude:'),
                          tableCellPadding('$lat')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Longitude:'),
                          tableCellPadding('$long')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Time:'),
                          tableCellPadding('$time')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Date:'),
                          tableCellPadding('$date')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Day:'),
                          tableCellPadding('$day')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Type of Day:'),
                          tableCellPadding('$dayType')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Session:'),
                          tableCellPadding('$session')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Temperature:'),
                          tableCellPadding('$temp')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Environment Type:'),
                          tableCellPadding('$_envType')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Location Name:'),
                          tableCellPadding('$_locName')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Environment:'),
                          tableCellPadding('$_env')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Floor:'),
                          tableCellPadding('$_floor')
                        ]),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: getSpeedStats,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: Text("Fetch Data".toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
