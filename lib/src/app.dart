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
import 'package:speed_test_dart/speed_test_dart.dart';

//Signal Strength
import 'package:flutter_internet_signal/flutter_internet_signal.dart';

//MethodChannel
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class DataCollection extends StatefulWidget {
  @override
  _DataCollectionState createState() => _DataCollectionState();
}

class _DataCollectionState extends State<DataCollection> {
  // All the data collection functions and data go here
  // ...
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

  //Strength Values
  String gsmStrength = '';
  String gsmData = '';
  String rssi = '';
  String asuLevel = '';
  String level = '';
  String gsm = '';
  String cdmaDbm = '';
  String cdmaEcio = '';
  String evdoDbm = '';
  String evdoEcio = '';
  String ecdoSnr = '';
  String cdmaLevel = '';
  String evdoLevel = '';
  String cdma = '';
  String lteStrength = '';
  String lteData = '';
  String rsrp = '';
  String rsrq = '';
  String rssnr = '';
  String cqi = '';
  String cqiTableIndex = '';
  String lte = '';

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

  static const platform = MethodChannel('com.example.methodchannel');

  Future<void> getStrength() async {
    var data = await platform.invokeMethod("messageFunction");
    print("got");
    print(data);
    print("Strength");
    print(data["lte"]);

    if (data["gsm"] != null) {
      var gsmData = data["gsm"];
      gsmStrength = gsmData["strength"].toString();
      rssi = gsmData["rssi"].toString();
      asuLevel = gsmData["asuLevel"].toString();
      level = gsmData["level"].toString();
      print("GSM Data:");
      print("Strength: $gsmStrength");
      print("Rssi: $rssi");
      print("Asu Level: $asuLevel");
      print("Level: $level");
    }

    if (data["cdma"] != null) {
      var cdmaData = data["cdma"];
      cdmaDbm = cdmaData["dbm"].toString();
      cdmaEcio = cdmaData["ecio"].toString();
      evdoDbm = cdmaData["evdoDbm"].toString();
      evdoEcio = cdmaData["evdoEcio"].toString();
      ecdoSnr = cdmaData["ecdoSnr"].toString();
      cdmaLevel = cdmaData["level"].toString();
      evdoLevel = cdmaData["evdoLevel"].toString();
      asuLevel = cdmaData["asuLevel"].toString();
      cdma = cdmaData["cdma"].toString();
      print("CDMA Data:");
      print("Dbm: $cdmaDbm");
      print("Ecio: $cdmaEcio");
      print("Evdo Dbm: $evdoDbm");
      print("Evdo Ecio: $evdoEcio");
      print("Ecdo Snr: $ecdoSnr");
      print("Level: $cdmaLevel");
      print("Evdo Level: $evdoLevel");
      print("Asu Level: $asuLevel");
      print("Type: $cdma");
    }

    if (data["lte"] != null) {
      var lteData = data["lte"];
      lteStrength = lteData["strength"].toString();
      rsrp = lteData["rsrp"].toString();
      rsrq = lteData["rsrq"].toString();
      rssnr = lteData["rssnr"].toString();
      level = lteData["level"].toString();
      cqi = lteData["cqi"].toString();
      cqiTableIndex = lteData["cqiTableIndex"].toString();
      lte = lteData["lte"].toString();
      print("LTE Data:");
      print("Strength: $lteStrength");
      print("Rsrp: $rsrp");
      print("Rsrq: $rsrq");
      print("Rssnr: $rssnr");
      print("Level: $level");
      print("Cqi: $cqi");
      print("Cqi Table Index: $cqiTableIndex");
      print("Type: $lte");
    }
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

  void SignalStrength() async {
    final FlutterInternetSignal internetSignal = FlutterInternetSignal();
    final int? mobileSignal = await internetSignal.getMobileSignalStrength();
    final int? wifiSignal = await internetSignal.getWifiSignalStrength();
    print('Result dBm mobile : ');
    print(mobileSignal);
    print('Result dBm wifi : ');
    print(wifiSignal);
    signal_strength = mobileSignal != null
        ? mobileSignal.toStringAsFixed(2)
        : wifiSignal != null
            ? wifiSignal.toStringAsFixed(2)
            : 'Unknown';
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

  Future<void> getSpeedStats() async {
    SignalStrength();
    detectMovement();
    getLocation();
    setTimeDetails();
    getConnectionDetails();
    _getWeather();
    getStrength();
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
      mobility,
      gsmStrength,
      gsmData,
      rssi,
      asuLevel,
      level,
      gsm,
      cdmaDbm,
      cdmaEcio,
      evdoDbm,
      evdoEcio,
      ecdoSnr,
      cdmaLevel,
      evdoLevel,
      level,
      asuLevel,
      cdma,
      lteStrength,
      lteData,
      rsrp,
      rsrq,
      rssnr,
      level,
      cqi,
      cqiTableIndex,
      lte,
    ];
    datas.add(row);
  }

  void sendToServer() async {
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
                        TableRow(children: [
                          tableCellPadding('1G GsmStrength:'),
                          tableCellPadding('$gsmStrength')
                        ]),
                        TableRow(children: [
                          tableCellPadding('1G GsmData:'),
                          tableCellPadding('$gsmData')
                        ]),
                        TableRow(children: [
                          tableCellPadding('1G rssi:'),
                          tableCellPadding('$rssi')
                        ]),
                        TableRow(children: [
                          tableCellPadding('1G AsuLevel'),
                          tableCellPadding('$asuLevel')
                        ]),
                        TableRow(children: [
                          tableCellPadding('1G level'),
                          tableCellPadding('$level')
                        ]),
                        TableRow(children: [
                          tableCellPadding('1G GSM:'),
                          tableCellPadding('$gsm')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G cdmaDbm:'),
                          tableCellPadding('$cdmaDbm')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G cdmaEcio'),
                          tableCellPadding('$cdmaEcio')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G evdoDbm:'),
                          tableCellPadding('$evdoDbm')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G evdoEcio:'),
                          tableCellPadding('$evdoEcio')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G ecdoSnr:'),
                          tableCellPadding('$ecdoSnr')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G cdmaLevel:'),
                          tableCellPadding('$cdmaLevel')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G level'),
                          tableCellPadding('$level')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G asuLevel:'),
                          tableCellPadding('$asuLevel')
                        ]),
                        TableRow(children: [
                          tableCellPadding('2G cdma:'),
                          tableCellPadding('$cdma')
                        ]),
                        TableRow(children: [
                          tableCellPadding('3G rsrp:'),
                          tableCellPadding('$rsrp')
                        ]),
                        TableRow(children: [
                          tableCellPadding('3G rsrq:'),
                          tableCellPadding('$rsrq')
                        ]),
                        TableRow(children: [
                          tableCellPadding('3G rssnr:'),
                          tableCellPadding('$rssnr')
                        ]),
                        TableRow(children: [
                          tableCellPadding('3G level:'),
                          tableCellPadding('$level')
                        ]),
                        TableRow(children: [
                          tableCellPadding('3G cqi:'),
                          tableCellPadding('$cqi')
                        ]),
                        TableRow(children: [
                          tableCellPadding('3G cqiTableIndex:'),
                          tableCellPadding('$cqiTableIndex')
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
      ),
    );
  }
}

class LocationBasedPrediction extends StatefulWidget {
  @override
  _LocationBasedPredictionState createState() =>
      _LocationBasedPredictionState();
}

class _LocationBasedPredictionState extends State<LocationBasedPrediction> {
  final _dataCollection = _DataCollectionState();
  String _locName = '';
  String _isp = '';
  String _long = '';
  String _lat = '';
  String _temp = '';
  String _climate = '';

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

      setState(() {
        _isp = isp1;
      });
    } else {
      setState(() {
        _isp = 'Unknown';
      });
    }
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _long = pos.longitude.toString();
      _lat = pos.latitude.toString();
    });
    await _getWeather();
  }

  Future<void> _getWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_long&appid=cd908d976e0a1eed6e522b5af2bf5ab7&units=metric';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      setState(() {
        _temp = data['main']['temp'].toString() ?? 'Unknown weather';
        _climate = data['weather'][0]['description'] ?? 'Unknown climate';
      });
    } else {
      setState(() {
        _temp = "Error in finding temperature";
        _climate = "Error in finding climate";
      });
    }
  }

  void showDataInTable(BuildContext context,
      _DataCollectionState dataCollection, String location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Data Table'),
          content: SizedBox(
            height: 500, // Set the height to make the table scrollable
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Property')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text('Mobility Status')),
                      DataCell(Text('${dataCollection.mobility}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Movement Speed')),
                      DataCell(Text('${dataCollection.velocity}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Signal Strength')),
                      DataCell(Text('${dataCollection.signal_strength}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('User ISP')),
                      DataCell(Text(_isp)), // Changed to isp
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Latitude')),
                      DataCell(Text(_lat)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Longitude')),
                      DataCell(Text(_long)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Time')),
                      DataCell(Text('${dataCollection.time}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Date')),
                      DataCell(Text('${dataCollection.date}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Day')),
                      DataCell(Text('${dataCollection.day}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Type of Day')),
                      DataCell(Text('${dataCollection.dayType}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Session')),
                      DataCell(Text('${dataCollection.session}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Temperature')),
                      DataCell(Text(_temp)), // Changed to temp
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Climate')),
                      DataCell(Text(_climate)), // Changed to climate
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Location')),
                      DataCell(Text(location)), // Added User Entered Location
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Based Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Location Based Prediction Screen'),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter location',
                ),
                onChanged: (value) {
                  setState(() {
                    _locName = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _dataCollection.getSpeedStats();
                await getConnectionDetails();
                await getLocation();
                showDataInTable(context, _dataCollection, _locName);
              },
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle predict using decision tree button click
                print('Predict using Decision Tree button clicked');
                // TODO: implement predict using decision tree logic
              },
              child: Text('Predict using Random Forest'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeBasedPrediction extends StatefulWidget {
  @override
  _TimeBasedPredictionState createState() => _TimeBasedPredictionState();
}

class _TimeBasedPredictionState extends State<TimeBasedPrediction> {
  final _dataCollection = _DataCollectionState();
  String _locName = '';
  String _isp = '';
  String _long = '';
  String _lat = '';
  String _temp = '';
  String _climate = '';
  String _time = '';

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

      setState(() {
        _isp = isp1;
      });
    } else {
      setState(() {
        _isp = 'Unknown';
      });
    }
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _long = pos.longitude.toString();
      _lat = pos.latitude.toString();
    });
    await _getWeather();
  }

  Future<void> _getWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_long&appid=cd908d976e0a1eed6e522b5af2bf5ab7&units=metric';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      setState(() {
        _temp = data['main']['temp'].toString() ?? 'Unknown weather';
        _climate = data['weather'][0]['description'] ?? 'Unknown climate';
      });
    } else {
      setState(() {
        _temp = "Error in finding temperature";
        _climate = "Error in finding climate";
      });
    }
  }

  void showDataInTable(
      BuildContext context, _DataCollectionState dataCollection) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Data Table'),
          content: SizedBox(
            height: 500, // Set the height to make the table scrollable
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Property')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text('Mobility Status')),
                      DataCell(Text('${dataCollection.mobility}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Movement Speed')),
                      DataCell(Text('${dataCollection.velocity}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Signal Strength')),
                      DataCell(Text('${dataCollection.signal_strength}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('User ISP')),
                      DataCell(Text(_isp)), // Changed to isp
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Latitude')),
                      DataCell(Text(_lat)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Longitude')),
                      DataCell(Text(_long)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Time')),
                      DataCell(Text('${_time}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Date')),
                      DataCell(Text('${dataCollection.date}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Day')),
                      DataCell(Text('${dataCollection.day}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Type of Day')),
                      DataCell(Text('${dataCollection.dayType}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Session')),
                      DataCell(Text('${dataCollection.session}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Temperature')),
                      DataCell(Text(_temp)), // Changed to temp
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Climate')),
                      DataCell(Text(_climate)), // Changed to climate
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Based Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time Based Prediction Screen'),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter time',
                ),
                onChanged: (value) {
                  setState(() {
                    _time = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _dataCollection.getSpeedStats();
                await getConnectionDetails();
                await _getWeather();
                await getLocation();
                showDataInTable(context, _dataCollection);
              },
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle predict using decision tree button click
                print('Predict using Decision Tree button clicked');
                // TODO: implement predict using decision tree logic
              },
              child: Text('Predict using Decision Tree'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeLocationPrediction extends StatefulWidget {
  @override
  _TimeLocationPredictionState createState() => _TimeLocationPredictionState();
}

class _TimeLocationPredictionState extends State<TimeLocationPrediction> {
  final _dataCollection = _DataCollectionState();
  String _locName = '';
  String _isp = '';
  String _long = '';
  String _lat = '';
  String _temp = '';
  String _climate = '';
  String _time = '';

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

      setState(() {
        _isp = isp1;
      });
    } else {
      setState(() {
        _isp = 'Unknown';
      });
    }
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _long = pos.longitude.toString();
      _lat = pos.latitude.toString();
    });
    await _getWeather();
  }

  Future<void> _getWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_long&appid=cd908d976e0a1eed6e522b5af2bf5ab7&units=metric';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      setState(() {
        _temp = data['main']['temp'].toString() ?? 'Unknown weather';
        _climate = data['weather'][0]['description'] ?? 'Unknown climate';
      });
    } else {
      setState(() {
        _temp = "Error in finding temperature";
        _climate = "Error in finding climate";
      });
    }
  }

  void showDataInTable(
      BuildContext context, _DataCollectionState dataCollection) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Data Table'),
          content: SizedBox(
            height: 500, // Set the height to make the table scrollable
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Property')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text('Mobility Status')),
                      DataCell(Text('${dataCollection.mobility}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Movement Speed')),
                      DataCell(Text('${dataCollection.velocity}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Signal Strength')),
                      DataCell(Text('${dataCollection.signal_strength}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('User ISP')),
                      DataCell(Text(_isp)), // Changed to isp
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Latitude')),
                      DataCell(Text(_lat)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Longitude')),
                      DataCell(Text(_long)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Time')),
                      DataCell(Text('${_time}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Date')),
                      DataCell(Text('${dataCollection.date}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Day')),
                      DataCell(Text('${dataCollection.day}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Type of Day')),
                      DataCell(Text('${dataCollection.dayType}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Session')),
                      DataCell(Text('${dataCollection.session}')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Temperature')),
                      DataCell(Text(_temp)), // Changed to temp
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Climate')),
                      DataCell(Text(_climate)), // Changed to climate
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Location')),
                      DataCell(Text(_locName)), // Added User Entered Location
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time and Location Based Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time and Location Based Prediction Screen'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter location',
                ),
                onChanged: (value) {
                  setState(() {
                    _locName = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter time',
                ),
                onChanged: (value) {
                  setState(() {
                    _time = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _dataCollection.getSpeedStats();
                await getConnectionDetails();
                await getLocation();
                showDataInTable(context, _dataCollection);
              },
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle predict using decision tree button click
                print('Predict using Decision Tree button clicked');
                // TODO: implement predict using decision tree logic
              },
              child: Text('Predict using Gradient Boosting'),
            ),
          ],
        ),
      ),
    );
  }
}

class PredictionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("PredictionScreen Clicked");
    return Scaffold(
      appBar: AppBar(title: Text('Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Prediction Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 50),
            Wrap(
              alignment: WrapAlignment.center, // align buttons to the center
              spacing: 20, // add some spacing between buttons
              runSpacing: 20, // add some spacing between rows
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Handle location based prediction button click
                    print('Location Based Prediction clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationBasedPrediction()),
                    );
                  },
                  child: Text('Location Based Prediction'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Handle time based prediction button click
                    print('Time Based Prediction clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimeBasedPrediction()),
                    );
                  },
                  child: Text('Time Based Prediction'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Handle both location and time based prediction button click
                    print('Both Location and Time Based Prediction clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimeLocationPrediction()),
                    );
                  },
                  child: Text('Both Location and Time Based Prediction'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    DataCollection(),
    PredictionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYNet',
      home: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
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
