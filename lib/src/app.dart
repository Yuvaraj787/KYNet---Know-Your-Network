import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speed_checker_plugin/speed_checker_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

// experimental
import 'package:speed_test_dart/classes/server.dart';
import 'package:flutter/services.dart';
import 'package:speed_test_dart/speed_test_dart.dart';


class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class PredictionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Prediction Screen'),
            ElevatedButton(
              onPressed: () {
                // Handle prediction button click
                print('Predict clicked');
              },
              child: Text('Predict'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  static const int bgColor = 0xFFE5E5E5;

  // Status and connection details
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

  // Environment details
  String _envType = 'Crowded';
  String _locName = '';
  String _env = 'Indoor';
  int _floor = 0;
  String temp = '';
  String mobility = 'Not Detected';
  String velocity = '0.0';
  String climate = '';
  String contributor = '';
  String signal_strength = '';

  final TextEditingController _locNameCtrl = TextEditingController();
  final SpeedCheckerPlugin _plugin = SpeedCheckerPlugin();
  late StreamSubscription<SpeedTestResult> _sub;

  late StreamSubscription<SpeedTestResult> _subscription;

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
      var name = data['isp'].toLowerCase();
      var isp1 = name.contains("jio")
          ? "Jio"
          : name.contains("airtel")
              ? "Airtel"
              : name.contains("bharti")
                  ? "Airtel"
                  : name.contains("vodafone")
                      ? "Vodafone"
                      : name.contains("bsnl")
                          ? "BSNL"
                          : "Other";

      print("ISP ISP");
      print(name);
      setState(() {
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

  String _connectionType = '';
  double _currentSpeed = 0;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;

  static const platform = MethodChannel('com.example.methodchannel');

  void getStrength() async {
    var data = await platform.invokeMethod("messageFunction");
    print("got");
    print(data);
  }

  void startTest() {
    _plugin.startSpeedTest();
    _subscription = _plugin.speedTestResultStream.listen((result) {
      setState(() {
        _ping = result.ping;
        _currentSpeed = result.currentSpeed;
        _downloadSpeed = result.downloadSpeed;
        _uploadSpeed = result.uploadSpeed;
        _connectionType = result.connectionType;
        _ip = result.ip;
        if (result.error.isNotEmpty) {
          Fluttertoast.showToast(msg: result.error.toString());
        }
      });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _subscription.cancel();
    });
  }

  void getSpeedStats() {
    getStrength();
    // detectMovement();
    // getLocation();
    // setTimeDetails();
    // getConnectionDetails();
  }

  List<List<String>> datas = [];

  void addEntry() {
    List<String> row = [
      time,
      lat,
      long,
      _downloadSpeed.toString(),
      _uploadSpeed.toString(),
      _ping.toString(),
      _connectionType,
      _isp,
      day,
      date,
      dayType,
      session,
      temp,
      climate,
      _envType,
      _locName,
      _floor.toString(),
      mobility
    ];
    datas.add(row);
  }

  void sendToServer() async {
    // send this datas (2d array of strings) to http://74.225.246.68/add_data POST method
    final url = Uri.parse('http://74.225.246.68/add_data');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'data': datas});
    print("collected data");
    print(datas);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Data sent successfully');
        datas.clear();
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
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
                        SizedBox(height: 20),
                        Text('Contributor Name',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          onChanged: (value) {
                            setState(() {
                              contributor = value;
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
                              '${_downloadSpeed.toStringAsFixed(2)} Mbps'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('Upload speed:'),
                          tableCellPadding(
                              '${_uploadSpeed.toStringAsFixed(2)} Mbps')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Signal Strength:'),
                          tableCellPadding('$signal_strength dBm')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Connection Type:'),
                          tableCellPadding('$_connectionType')
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
                          tableCellPadding('$temp c')
                        ]),
                        TableRow(children: [
                          tableCellPadding('Climate'),
                          tableCellPadding('$climate')
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
                        TableRow(children: [
                          tableCellPadding('Contributor Name:'),
                          tableCellPadding('$contributor')
                        ]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20), // Increase the top gap here
                    child: Wrap(
                      spacing: 10, // Horizontal space between buttons
                      runSpacing: 10, // Vertical space between rows of buttons
                      alignment:
                          WrapAlignment.center, // Center align the buttons
                      children: [
                        ElevatedButton(
                          onPressed: getSpeedStats,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: Text("Fetch Data".toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: startTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: Text("Test Speed".toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: addEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: Text("Add Entry".toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: sendToServer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                              "Send Data ( ".toUpperCase() +
                                  datas.length.toString() +
                                  " rows in memory )",
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.data_usage),
              label: 'Data Collection',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Prediction',
            ),
          ],
          onTap: (int index) {
            switch (index) {
              case 0:
                print("Data Collection Clicked");
                break;
              case 1:
                print("Prediction Clicked");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PredictionScreen()),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}

class _SpeedState extends State<MyApp> {
  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];

  double downloadRate = 0;
  double uploadRate = 0;

  bool readyToTest = false;
  bool loadingDownload = false;
  bool loadingUpload = false;
  String status = "fetched servers";
  String noOfServers = 'Not got';

  Future<void> setBestServers() async {
    final settings = await tester.getSettings();
    final servers = settings.servers;

    final _bestServersList = await tester.getBestServers(
      servers: servers,
    );

    print("best serers ready");
    print(_bestServersList.length);

    setState(() {
      status = "fetched";
      noOfServers = _bestServersList.length.toString();
      bestServersList = _bestServersList;
      readyToTest = true;
    });
  }

  Future<void> _testDownloadSpeed() async {
    print("started");
    setState(() {
      loadingDownload = true;
    });
    final _downloadRate =
        await tester.testDownloadSpeed(servers: [bestServersList[0]]);
    setState(() {
      downloadRate = _downloadRate;
      loadingDownload = false;
    });
  }

  Future<void> _testUploadSpeed() async {
    setState(() {
      loadingUpload = true;
    });

    final _uploadRate = await tester.testUploadSpeed(servers: bestServersList);

    setState(() {
      uploadRate = _uploadRate;
      loadingUpload = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBestServers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Speed Test Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Download Test: $status and $noOfServers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (loadingDownload)
                Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Testing download speed...'),
                  ],
                )
              else
                Text('Download rate  ${downloadRate.toStringAsFixed(2)} Mb/s'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadingDownload
                    ? null
                    : () async {
                        if (!readyToTest || bestServersList.isEmpty) return;
                        await _testDownloadSpeed();
                      },
                child: const Text('Start'),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Upload Test:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (loadingUpload)
                Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Testing upload speed...'),
                  ],
                )
              else
                Text('Upload rate ${uploadRate.toStringAsFixed(2)} Mb/s'),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: loadingUpload
                    ? null
                    : () async {
                        if (!readyToTest || bestServersList.isEmpty) return;
                        await _testUploadSpeed();
                      },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}