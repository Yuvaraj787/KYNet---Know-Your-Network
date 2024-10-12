import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speed_checker_plugin/speed_checker_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';

import 'package:shared_preferences/shared_preferences.dart';

// experimental
import 'package:speed_test_dart/classes/server.dart';
import 'package:flutter/services.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

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
  static const int bgColor = 0xFFE5E5E5;

  String _ip = '';
  String _isp = '';

  String lat = '';
  String long = '';

  String date = '';
  String time = '';
  String day = '';
  String dayType = '';
  String session = '';

  int _ping = 0;

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

  var gsmStrength;
  var gsmData;
  var rssi;
  var asuLevel;
  var level;
  var gsm;
  var cdmaDbm;
  var cdmaEcio;
  var evdoDbm;
  var evdoEcio;
  var ecdoSnr;
  var cdmaLevel;
  var evdoLevel;
  var cdma;
  var lteStrength;
  var lteData;
  var rsrp;
  var rsrq;
  var rssnr;
  var cqi;
  var cqiTableIndex;
  var lte;

  final TextEditingController _locNameCtrl = TextEditingController();
  final SpeedCheckerPlugin _plugin = SpeedCheckerPlugin();
  late StreamSubscription<SpeedTestResult> _sub;

  late StreamSubscription<SpeedTestResult> _subscription;

  TextEditingController _controller_2 = TextEditingController();

  void loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedInput = prefs.getString('userInput') ?? '';
    _controller_2.text = savedInput;
  }

  _saveInput(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInput', value);
    print("saved");
  }

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
  var nr_csicqi,
      nr_csicqiti,
      nr_csirsrp,
      nr_csisinr,
      nr_dbm,
      nr_rsrq,
      nr_rsrp,
      nr_sssinr,
      nr_csirsrq,
      nr_timing;
  var asu_level,
      gsm_band,
      cdma_band,
      lte_band,
      nr_band,
      gsm_asuLevel,
      cdma_asuLevel;

  Future<void> getStrength() async {
    var data = await platform.invokeMethod("messageFunction");
    print("got");
    print(data);
    print("Strength");
    print(data["lte"]);

    if (data["gsm"] != null) {
      var gsmData = data["gsm"];
      gsmStrength = gsmData["strength"].toString();
      signal_strength = gsmStrength;
      rssi = gsmData["rssi"].toString();
      gsm_asuLevel = gsmData["asuLevel"].toString();
      level = gsmData["level"].toString();
      print("GSM Data:");
      print("Strength: $gsmStrength");
      print("Rssi: $rssi");
      print("Asu Level: $gsm_asuLevel");
      print("Level: $level");
    }

    if (data["cdma"] != null) {
      var cdmaData = data["cdma"];
      cdmaDbm = cdmaData["dbm"].toString();
      signal_strength = cdmaDbm;
      cdmaEcio = cdmaData["ecio"].toString();
      evdoDbm = cdmaData["evdoDbm"].toString();
      evdoEcio = cdmaData["evdoEcio"].toString();
      ecdoSnr = cdmaData["ecdoSnr"].toString();
      cdmaLevel = cdmaData["level"].toString();
      evdoLevel = cdmaData["evdoLevel"].toString();
      cdma_asuLevel = cdmaData["asuLevel"].toString();
      print("CDMA Data:");
      print("Dbm: $cdmaDbm");
      print("Ecio: $cdmaEcio");
      print("Evdo Dbm: $evdoDbm");
      print("Evdo Ecio: $evdoEcio");
      print("Ecdo Snr: $ecdoSnr");
      print("Level: $cdmaLevel");
      print("Evdo Level: $evdoLevel");
      print("Asu Level: $cdma_asuLevel");
    }

    if (data["lte"] != null) {
      var lteData = data["lte"];
      lteStrength = lteData["strength"].toString();
      rsrp = lteData["rsrp"].toString();
      signal_strength = rsrp;
      rsrq = lteData["rsrq"].toString();
      rssnr = lteData["rssnr"].toString();
      level = lteData["level"].toString();
      asu_level = lteData["asuLevel"].toString();
      cqi = lteData["cqi"].toString();
      cqiTableIndex = lteData["cqiTableIndex"].toString();
      lte_band = lteData["bands"].toString();
      print("LTE Data:");
      print("Strength: $lteStrength");
      print("Rsrp: $rsrp");
      print("Rsrq: $rsrq");
      print("Rssnr: $rssnr");
      print("Level: $level");
      print("Cqi: $cqi");
      print("Cqi Table Index: $cqiTableIndex");
    }

    if (data["nr"] != null) {
      var nrData = data["nr"];
      nr_rsrp = nrData["ssRsrp"];
      signal_strength = nr_rsrp;
      nr_rsrq = nrData["ssRsrq"];
      nr_sssinr = nrData["ssSinr"];
      nr_dbm = nrData["dbm"];
      nr_csirsrp = nrData["csiRsrp"];
      nr_csirsrq = nrData["csiRsrq"];
      nr_csisinr = nrData["csiSinr"];
      nr_csicqi = nrData["csiCqiReport"];
      nr_csicqiti = nrData["csiCqiTableIndex"];
      nr_timing = nrData["timingAdvanceMicros"];
      nr_band = nrData["bands"].toString();
    }
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      long = pos.longitude.toString();
      lat = pos.latitude.toString();
    });
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
      double speedMps = position.speed;
      String category = '';
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

      print("Category: $category");
    });
  }

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

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  bool _isCollectingData = false;

  void startDataCollection() {
    print("vela start");
    if (!_isCollectingData) {
      _isCollectingData = true;
      startTest();
    }
  }

  void stopDataCollection() {
    print("vela end");
    if (_isCollectingData) {
      _isCollectingData = false;
    }
  }

  var testStatus = "";

  void startTest() {
    print("speed test started");
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

        if (result.status != "Speed test finished") {
          setState(() {
            testStatus = "Testing " +
                result.status +
                " Speed ( " +
                result.percent.toString() +
                " % ) Completed";
          });
        } else {
          setState(() {
            testStatus = "Speed Test Complete";
            getOtherMetricsAndRepeat();
          });
        }
      });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _subscription.cancel();
      _isCollectingData = false;
    });
  }

  void getOtherMetricsAndRepeat() async {
    await getOtherMetrics();
    await sendToServer();
    print("waiting 5 seconds");
    await Future.delayed(Duration(seconds: 5));
    if (_isCollectingData) startTest();
  }

  Future<void> getOtherMetrics() async {
    detectMovement();
    await getLocation();
    await _getWeather();
    setTimeDetails();
    await getConnectionDetails();
    await getStrength();
    // addEntry();
  }

  List<List<dynamic>> datas = [];

  List<dynamic> last_inserted = [];

  Future<void> sendToServer() async {
    List<dynamic> row = [
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
      velocity,
      gsmStrength,
      gsm_asuLevel,
      rssi,
      cdmaDbm,
      cdmaEcio,
      evdoDbm,
      evdoEcio,
      ecdoSnr,
      cdma_asuLevel,
      cdma_band,
      rsrp,
      rsrq,
      rssnr,
      cqi,
      lte_band,
      nr_dbm,
      nr_rsrp,
      nr_rsrq,
      nr_sssinr,
      nr_csicqi,
      nr_csirsrp,
      nr_csirsrq,
      nr_band,
      nr_timing,
      contributor,
      _env,
    ];
    final url = Uri.parse('http://74.225.246.68/add_data');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'data': row});
    print("collected data");
    print(row);

    if (_downloadSpeed == 0.0 || _uploadSpeed == 0.0 || _ping == 0) return;

    if (row == last_inserted) {
      print("duplicated rows detected");
      return;
    }
    

    final listEquality = ListEquality();

    if (listEquality.equals(row, last_inserted)) {
      print("advance security ");
      return;
    };

    last_inserted = List.from(row);

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Data sent successfully');
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Environment Type',
                                    style: TextStyle(
                                      fontSize:
                                          14, // Slightly reduced font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: _envType,
                                    items: <String>[
                                      'Free',
                                      'Crowded',
                                      'Moderate'
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _envType = newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location Name',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextField(
                                    controller: _locNameCtrl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _locName = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Environment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: _env,
                                    items: <String>['Indoor', 'Outdoor']
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _env = newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Floor',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DropdownButton<int>(
                                    value: _floor,
                                    items: List.generate(5, (index) => index)
                                        .map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()),
                                      );
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
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Contributor Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: _controller_2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _saveInput(value);
                            print("passed");
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
                    child: Text(
                        'Data Fetching '.toUpperCase() +
                            (_isCollectingData ? " Ongoing " : "Stopped"),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(testStatus,
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
                          tableCellPadding('( 2G ) GsmStrength:'),
                          tableCellPadding('$gsmStrength')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 2G ) GsmData:'),
                          tableCellPadding('$gsmData')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 2G ) rssi:'),
                          tableCellPadding('$rssi')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 2G ) AsuLevel'),
                          tableCellPadding('$gsm_asuLevel')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 2G ) level'),
                          tableCellPadding('$level')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 2G ) band:'),
                          tableCellPadding('$gsm_band')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) cdmaDbm:'),
                          tableCellPadding('$cdmaDbm')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) cdmaEcio'),
                          tableCellPadding('$cdmaEcio')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) evdoDbm:'),
                          tableCellPadding('$evdoDbm')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) evdoEcio:'),
                          tableCellPadding('$evdoEcio')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) ecdoSnr:'),
                          tableCellPadding('$ecdoSnr')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) cdmaLevel:'),
                          tableCellPadding('$cdmaLevel')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) asuLevel:'),
                          tableCellPadding('$cdma_asuLevel')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 3G ) band:'),
                          tableCellPadding('$cdma_band')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 4G ) rsrp:'),
                          tableCellPadding('$rsrp')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 4G ) rsrq:'),
                          tableCellPadding('$rsrq')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 4G ) rssnr:'),
                          tableCellPadding('$rssnr')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 4G ) asuLevel:'),
                          tableCellPadding('$asu_level')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 4G ) cqi:'),
                          tableCellPadding('$cqi')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 4G ) band:'),
                          tableCellPadding('$lte_band')
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) rsrp:'),
                          tableCellPadding('$nr_rsrp'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) rsrq:'),
                          tableCellPadding('$nr_rsrq'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) ssinr:'),
                          tableCellPadding('$nr_sssinr'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) dbm:'),
                          tableCellPadding('$nr_dbm'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) csi_rsrp:'),
                          tableCellPadding('$nr_csirsrp'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) csi_rsrq:'),
                          tableCellPadding('$nr_csirsrq'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) csi_sinr:'),
                          tableCellPadding('$nr_csisinr'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) csi_cqi_report:'),
                          tableCellPadding('$nr_csicqi'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) timing_advance_micros:'),
                          tableCellPadding('$nr_timing'),
                        ]),
                        TableRow(children: [
                          tableCellPadding('( 5G ) band:'),
                          tableCellPadding('$nr_band')
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
                          onPressed: startDataCollection,
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
                          child: Text("Start Data Collection".toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: stopDataCollection,
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
                          child: Text("Stop Data Collection".toUpperCase(),
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

class ListEquality<T> {
  bool equals(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class CustomDropdownButton<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final void Function(T?) onChanged;

  const CustomDropdownButton({
    Key? key,
    required this.items,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropdownButtonState<T> createState() =>
      _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: widget.value,
      items: widget.items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: widget.onChanged,
    );
  }
} // ignore: must_be_immutable

class CustomTextField extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onChanged;

  const CustomTextField({
    Key? key,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
} // ignore: must_be_immutable

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final void Function(T?) onChanged;

  const CustomDropdownButtonFormField({
    Key? key,
    required this.items,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropdownButtonFormFieldState<T> createState() =>
      _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T>
    extends State<CustomDropdownButtonFormField<T>> {
  late T? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: _value,
      items: widget.items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (T? newValue) {
        setState(() {
          _value = newValue;
        });
        widget.onChanged(newValue);
      },
    );
  }
} // ignore: must_be_immutable

class CustomTextFormField extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onChanged;

  const CustomTextFormField({
    Key? key,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
} // ignore: must_be_immutable

class CustomDropdownButton1<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final void Function(T?) onChanged;

  const CustomDropdownButton1({
    Key? key,
    required this.items,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropdownButtonState<T> createState() =>
      _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState1<T> extends State<CustomDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: widget.value,
      items: widget.items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: widget.onChanged,
    );
  }
}

class CurrentLocationPrediction extends StatefulWidget {
  @override
  _CurrentLocationPredictionState createState() =>
      _CurrentLocationPredictionState();
}

class PredictionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Prediction Screen Clicked");
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
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
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
                    print('Current Location Prediction clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CurrentLocationPrediction()),
                    );
                  },
                  child: Text('Current Location Prediction'),
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
                    print('Custom Location Prediction clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomLocationPrediction()),
                    );
                  },
                  child: Text('Custom Location Prediction'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentLocationPredictionState extends State<CurrentLocationPrediction> {
  final _dataCollection = _DataCollectionState();
  String _isp = '';
  String _long = '';
  String _lat = '';
  String _temp = '';
  String _climate = '';
  String long = '';
  String lat = '';
  String date = '';
  String time = '';
  String days = '';
  String day = '';
  String dayType = '';
  int hour = 0;
  String session = '';
  String temp = '';
  int _ping = 0;
  String _envType = 'Crowded';
  String _locName = '';
  String _env = 'Indoor';
  int _floor = 0;
  String _ip = "";
  String mobility = 'Not Detected';
  String velocity = '0.0';
  String climate = '';
  String contributor = '';
  String signal_strength = '';
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  String _connectionType = "";

  var gsmStrength;
  var gsmData;
  var rssi;
  var asuLevel;
  var level;
  var gsm;
  var cdmaDbm;
  var cdmaEcio;
  var evdoDbm;
  var evdoEcio;
  var ecdoSnr;
  var cdmaLevel;
  var evdoLevel;
  var cdma;
  var lteStrength;
  var lteData;
  var rsrp;
  var rsrq;
  var rssnr;
  var cqi;
  var cqiTableIndex;
  var lte;

  var nr_csicqi,
      nr_csicqiti,
      nr_csirsrp,
      nr_csisinr,
      nr_dbm,
      nr_rsrq,
      nr_rsrp,
      nr_sssinr,
      nr_csirsrq,
      nr_timing;
  var asu_level,
      gsm_band,
      cdma_band,
      lte_band,
      nr_band,
      gsm_asuLevel,
      cdma_asuLevel;

  Future<void> getOtherMetrics() async {
    detectMovement();
    await getLocation();
    await _getWeather();
    setTimeDetails();
    await getConnectionDetails();
    await getStrength();
    setState(() {
      _dataCollection.time = time;
      _dataCollection.date = date;
      _dataCollection.day = day;
      _dataCollection.dayType = dayType;
      _dataCollection.session = session;
      _dataCollection.mobility = mobility;
      _dataCollection.velocity = velocity;
      _dataCollection.signal_strength = signal_strength;
      _dataCollection.lat = lat;
      _dataCollection.long = long;
      _dataCollection.temp = temp;
      _dataCollection.climate = climate;
    });
  }

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
      signal_strength = gsmStrength;
      rssi = gsmData["rssi"].toString();
      gsm_asuLevel = gsmData["asuLevel"].toString();
      level = gsmData["level"].toString();
      print("GSM Data:");
      print("Strength: $gsmStrength");
      print("Rssi: $rssi");
      print("Asu Level: $gsm_asuLevel");
      print("Level: $level");
    }

    if (data["cdma"] != null) {
      var cdmaData = data["cdma"];
      cdmaDbm = cdmaData["dbm"].toString();
      signal_strength = cdmaDbm;
      cdmaEcio = cdmaData["ecio"].toString();
      evdoDbm = cdmaData["evdoDbm"].toString();
      evdoEcio = cdmaData["evdoEcio"].toString();
      ecdoSnr = cdmaData["ecdoSnr"].toString();
      cdmaLevel = cdmaData["level"].toString();
      evdoLevel = cdmaData["evdoLevel"].toString();
      cdma_asuLevel = cdmaData["asuLevel"].toString();
      print("CDMA Data:");
      print("Dbm: $cdmaDbm");
      print("Ecio: $cdmaEcio");
      print("Evdo Dbm: $evdoDbm");
      print("Evdo Ecio: $evdoEcio");
      print("Ecdo Snr: $ecdoSnr");
      print("Level: $cdmaLevel");
      print("Evdo Level: $evdoLevel");
      print("Asu Level: $cdma_asuLevel");
    }

    if (data["lte"] != null) {
      var lteData = data["lte"];
      lteStrength = lteData["strength"].toString();
      rsrp = lteData["rsrp"].toString();
      signal_strength = rsrp;
      rsrq = lteData["rsrq"].toString();
      rssnr = lteData["rssnr"].toString();
      level = lteData["level"].toString();
      asu_level = lteData["asuLevel"].toString();
      cqi = lteData["cqi"].toString();
      cqiTableIndex = lteData["cqiTableIndex"].toString();
      lte_band = lteData["bands"].toString();
      print("LTE Data:");
      print("Strength: $lteStrength");
      print("Rsrp: $rsrp");
      print("Rsrq: $rsrq");
      print("Rssnr: $rssnr");
      print("Level: $level");
      print("Cqi: $cqi");
      print("Cqi Table Index: $cqiTableIndex");
    }

    if (data["nr"] != null) {
      var nrData = data["nr"];
      nr_rsrp = nrData["ssRsrp"];
      signal_strength = nr_rsrp;
      nr_rsrq = nrData["ssRsrq"];
      nr_sssinr = nrData["ss Sinr"];
      nr_dbm = nrData["dbm"];
      nr_csirsrp = nrData["csiRsrp"];
      nr_csirsrq = nrData["csiRsrq"];
      nr_csisinr = nrData["csiSinr"];
      nr_csicqi = nrData["csiCqiReport"];
      nr_csicqiti = nrData["csiCqiTableIndex"];
      nr_timing = nrData["timingAdvanceMicros"];
      nr_band = nrData["bands"].toString();
    }
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _long = pos.longitude.toString();
      _lat = pos.latitude.toString();
    });
    print("location p");
    print(_long);
    print(_lat);
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
      double speedMps = position.speed;
      String category = '';
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
        print("Mobility");
        print(mobility);
        print("Velocity");
        print(velocity);
      });

      print("Category: $category");
    });
  }


  Future<void> dataToServer() async {
    List<dynamic> row = [
      time,
      _lat,
      _long,
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
      velocity,
      gsmStrength,
      gsm_asuLevel,
      rssi,
      cdmaDbm,
      cdmaEcio,
      evdoDbm,
      evdoEcio,
      ecdoSnr,
      cdma_asuLevel,
      cdma_band,
      rsrp,
      rsrq,
      rssnr,
      cqi,
      lte_band,
      nr_dbm,
      nr_rsrp,
      nr_rsrq,
      nr_sssinr,
      nr_csicqi,
      nr_csirsrp,
      nr_csirsrq,
      nr_band,
      nr_timing,
      contributor,
      _env,
    ];
    final url = Uri.parse('http://74.225.246.68/predict');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'data': row});
    print("collected data");
    print(row);

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Data sent successfully');
        print(response.body);
        var data = json.decode(response.body);
        data = data['output'];
        double downloadSpeed = data['download_speed'] ?? 'Unknown ';
        double uploadSpeed = data['upload_speed'] ?? 'Unknown';
        double latency = data['latency'] ?? 'Unknown';
        double rsrp = data['rsrp'] ?? 'Unknown';

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Predicted Values'),
              content: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    Text('Download Speed: $downloadSpeed'),
                    Text('Upload Speed: $uploadSpeed'),
                    Text('Latency: $latency'),
                    Text('RSRP: $rsrp'),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
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
            height: 500,
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
                      DataCell(Text(mobility)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Movement Speed')),
                      DataCell(Text(velocity)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Signal Strength')),
                      DataCell(Text(signal_strength)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('User ISP')),
                      DataCell(Text(_isp)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Latitude')),
                      DataCell(Text(lat)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Longitude')),
                      DataCell(Text(long)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Time')),
                      DataCell(Text(time)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Date')),
                      DataCell(Text(date)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Day')),
                      DataCell(Text(day)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Type of Day')),
                      DataCell(Text(dayType)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Session')),
                      DataCell(Text(session)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Temperature')),
                      DataCell(Text(temp)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Climate')),
                      DataCell(Text(climate)),
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

  Future<void> _getWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_long&appid=cd908d976e0a1eed6e522b5af2bf5ab7&units=metric';
    final res = await http.get(Uri.parse(url));
    print("Status Code");
    print(res.statusCode);
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


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Location Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Location Prediction Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("working............");
                detectMovement();
                await getLocation();
                await _getWeather();
                setTimeDetails();
                await getConnectionDetails();
                await getStrength();
                showDataInTable(context, _dataCollection);
              },
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await dataToServer();
                print('Prediction');
              },
              child: Text('Predict'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomLocationPrediction extends StatefulWidget {
  @override
  _CustomLocationPredictionState createState() =>
      _CustomLocationPredictionState();
}

class _CustomLocationPredictionState extends State<CustomLocationPrediction> {
  final _dataCollection = _DataCollectionState();
  String _isp = '';
  String _long = '';
  String _lat = '';
  String _temp = '';
  String _climate = '';
  String _customLocation = '';

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
            height: 500,
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
                      DataCell(Text(_isp)),
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
                      DataCell(Text(_temp)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Climate')),
                      DataCell(Text(_climate)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Location')),
                      DataCell(Text(_customLocation)),
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
      appBar: AppBar(title: const Text('Custom Location Prediction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Custom Location Prediction Screen'),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter custom location',
              ),
              onChanged: (value) {
                setState(() {
                  _customLocation = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // await _dataCollection.getSpeedStats();
                await getConnectionDetails();
                await _getWeather();
                await _dataCollection.getOtherMetrics();
                showDataInTable(context, _dataCollection);
              },
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print('Predict using Decision Tree button clicked');
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
