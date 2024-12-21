import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class Picker extends StatefulWidget {
  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  final Dio _dio = Dio();

  var lat;
  var long;
  TimeOfDay? selectedTime;
  String? selectedOperator; // To store the selected operator
  String? selectedMobility; // To store the selected mobility status

  @override
  void initState() {
    super.initState();
  }

  // Handle the map tap action
  void _handleTap(TapPosition point, latLng.LatLng tappedPoint) {
    setState(() {
      lat = tappedPoint.latitude;
      long = tappedPoint.longitude;
    });
  }

  var selectedMobilityStatus;
  String giveCollegeLocation(double latitude, double longitude) {
    final Map<String, List<List<double>>> locations = {
      "Red Building": [
        [13.0106469263, 13.0115584619],
        [80.2345254977, 80.2364459594]
      ],
      "IT department": [
        [13.0127887755, 13.0130829729],
        [80.2358313919, 80.2362461123]
      ],
      "Printing Technology department": [
        [13.0131002008, 13.0135377581],
        [80.234950507, 80.2358287049]
      ],
      "Knowledge Park": [
        [13.0134038425, 13.0139730405],
        [80.2350035079, 80.2359345894]
      ],
      "Printing department road": [
        [13.0130563693, 13.0132195397],
        [80.2349427323, 80.2357248775]
      ],
      "Power system department": [
        [13.0127609426, 13.0131747455],
        [80.2348974879, 80.2357569503]
      ],
      "ECE department": [
        [13.0123377022, 13.0128724407],
        [80.2348227688, 80.2357155031]
      ],
      "CSE department": [
        [13.0122552884, 13.0128464302],
        [80.2356945124, 80.2362179826]
      ],
      "Science & Humanities Block": [
        [13.0117443695, 13.0124159534],
        [80.2347283788, 80.2365721883]
      ],
      "Vivekananda Auditorium": [
        [13.0114039009, 13.011855302],
        [80.2357608858, 80.2364878071]
      ],
      "CPDE": [
        [13.011498538, 13.0119360268],
        [80.2351888109, 80.2358171414]
      ],
      "Math Department": [
        [13.0111687835, 13.0115386752],
        [80.235159064, 80.2358128224]
      ],
      "RED Building": [
        [13.0106132908, 13.0113415056],
        [80.2344936148, 80.2363769027]
      ],
      "HOSTEL": [
        [13.0142035149, 13.0152114705],
        [80.2369730816, 80.2403523008]
      ],
      "Hostel": [
        [13.0148883167, 13.0157400337],
        [80.2370686033, 80.2404260293]
      ],
      "Blue Shed": [
        [13.0130537131, 13.0135436682],
        [80.2356491041, 80.2363451209]
      ],
      "College Road": [
        [13.0106663118, 13.0132207973],
        [80.2363274277, 80.2367859476]
      ],
      "IT department Road": [
        [13.0123336216, 13.0131060849],
        [80.2356372534, 80.2358094323]
      ],
      "Ground": [
        [13.0106263869, 13.0124589081],
        [80.2365263802, 80.2397439598]
      ],
      "Mech Department": [
        [13.0110955561, 13.0131682056],
        [80.2324025618, 80.2333743176]
      ],
      "EEE Department": [
        [13.0112133111, 13.0116299416],
        [80.233775207, 80.2345744842]
      ],
      "Manufacturing Department": [
        [13.0115340867, 13.0122305407],
        [80.2338114139, 80.2346615185]
      ],
      "Industrial Department": [
        [13.009825765, 13.0104024553],
        [80.2336158562, 80.2342973906]
      ],
      "NCC Area": [
        [13.0121811587, 13.0129828063],
        [80.2338946883, 80.2348276967]
      ],
    };

    for (var loc in locations.entries) {
      var latRange = loc.value[0];
      var longRange = loc.value[1];
      if (latitude >= latRange[0] &&
          latitude <= latRange[1] &&
          longitude >= longRange[0] &&
          longitude <= longRange[1]) {
        return loc.key;
      }
    }
    return "Outside Campus";
  }

  Map<String, String> predict(List<dynamic> data) {
    // Extract and map required values (modify as needed)
    double lat = data[1] is String
        ? double.tryParse(data[1]) ?? 0.0
        : data[1].toDouble();
    double long = data[2] is String
        ? double.tryParse(data[2]) ?? 0.0
        : data[2].toDouble();

    int currentHour = data[0] is String
        ? int.tryParse(data[0].split(':')[0]) ?? 0
        : data[0].toInt();
    print(currentHour);
    String location = giveCollegeLocation(lat, long);

    // Generate network metrics based on location and time
    double downloadSpeed = getDownloadSpeed(location, currentHour);
    double uploadSpeed = getUploadSpeed(location, currentHour);
    double latency = getLatency(location, currentHour);
    double rsrp = getRSRP(downloadSpeed);

    return {
      'downloadSpeed': downloadSpeed.toStringAsFixed(2),
      'uploadSpeed': uploadSpeed.toStringAsFixed(2),
      'latency': latency.toStringAsFixed(1),
      'rsrp': rsrp.toStringAsFixed(1),
    };
  }

  double getDownloadSpeed(String location, int hour) {
    if (location == "Vivekananda Auditorium") {
      if (hour >= 6 && hour < 9) return randomInRange(100, 200);
      if (hour >= 9 && hour < 17) return randomInRange(50, 150);
      return randomInRange(100, 300);
    } else if ([
      "IT department",
      "Printing department road",
      "IT department Road"
    ].contains(location)) {
      if (hour >= 6 && hour < 9) return randomInRange(20, 150);
      if (hour >= 9 && hour < 17) return randomInRange(20, 80);
      return randomInRange(20, 150);
    } else if (location == "Knowledge Park") {
      if (hour >= 9 && hour < 17) return randomInRange(0, 20);
      return randomInRange(0, 30);
    } else if (["Math Department", "Red Building"].contains(location)) {
      if (hour >= 9 && hour < 17) return randomInRange(1, 50);
      return randomInRange(0, 200);
    } else if (location == "Ground") {
      if (hour >= 9 && hour < 17) return randomInRange(0, 100);
      return randomInRange(20, 150);
    } else if (["CSE department", "Science & Humanities Block"]
        .contains(location)) {
      if (hour >= 9 && hour < 17) return randomInRange(0, 50);
      return randomInRange(20, 180);
    } else {
      if (hour >= 9 && hour < 17) return randomInRange(0, 50);
      return randomInRange(20, 180);
    }
  }

// Helper to generate upload speed
  double getUploadSpeed(String location, int hour) {
    if (location == "Vivekananda Auditorium") {
      if (hour >= 6 && hour < 9) return randomInRange(40, 80);
      if (hour >= 9 && hour < 17) return randomInRange(10, 50);
      return randomInRange(20, 90);
    } else if ([
      "IT department",
      "Printing department road",
      "IT department Road"
    ].contains(location)) {
      if (hour >= 6 && hour < 9) return randomInRange(10, 40);
      if (hour >= 9 && hour < 17) return randomInRange(10, 30);
      return randomInRange(10, 40);
    } else if (location == "Knowledge Park") {
      return randomInRange(0, 10);
    } else if (["Math Department", "Red Building"].contains(location)) {
      if (hour >= 9 && hour < 17) return randomInRange(0, 20);
      return randomInRange(0, 10);
    } else if (location == "Ground") {
      if (hour >= 9 && hour < 17) return randomInRange(0, 20);
      return randomInRange(0, 20);
    } else if (["CSE department", "Science & Humanities Block"]
        .contains(location)) {
      if (hour >= 9 && hour < 17) return randomInRange(0, 20);
      return randomInRange(4, 30);
    } else {
      if (hour >= 9 && hour < 17) return randomInRange(0, 20);
      return randomInRange(4, 30);
    }
  }

// Helper to generate latency
  double getLatency(String location, int hour) {
    if (location == "Knowledge Park") {
      return randomInRange(5, 40);
    } else if (location == "Ground" ||
        ["Math Department", "Red Building"].contains(location)) {
      return randomInRange(5, 30);
    } else {
      return randomInRange(5, 30);
    }
  }

// Helper to generate RSRP
  double getRSRP(double downloadSpeed) {
    if (downloadSpeed >= 0 && downloadSpeed <= 30)
      return randomInRange(-100, -90);
    if (downloadSpeed > 30 && downloadSpeed <= 50)
      return randomInRange(-90, -80);
    if (downloadSpeed > 50 && downloadSpeed <= 200)
      return randomInRange(-80, -60);
    if (downloadSpeed > 200 && downloadSpeed <= 300)
      return randomInRange(-60, -50);
    return randomInRange(-50, -45);
  }

// Utility to generate random double within range
  double randomInRange(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }

  Future<void> dataToServer() async {
    // Determine velocity based on selected mobility status
    double velocity = 0.0; // Default velocity
    if (selectedMobilityStatus == 'No Movement') {
      velocity = 0.0;
    } else if (selectedMobilityStatus == 'Slow Walking') {
      velocity = 0.5;
    } else if (selectedMobilityStatus == 'Walking') {
      velocity = 1.5;
    } else if (selectedMobilityStatus == 'Running') {
      velocity = 3.0;
    } else if (selectedMobilityStatus == 'Moving in Vehicle') {
      velocity = 10.0; // Example value for vehicle speed
    }

    // Determine session based on selected time
    String session = 'Night'; // Default session
    if (selectedTime != null) {
      int hour = selectedTime!.hour;
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

    // {'lat': 13.0152118, 'long': 80.23958, 'connection_type_4G': 1, 'isp_Airtel': 1, 'day_Saturday': 1, 'temperature': 28.7, 'climate_mist': 1, 'env_type_Free': 1, 'mobility_No movement': 1, 'floor': 0, 'movement_speed': 0.1, 'session_Morning': 1, 'day_type_Weekday': 1, 'hour': 11, 'env_Outdoor': 1}

    // Determine day type (simplified for demonstration)
    String dayType = DateTime.now().weekday >= 6 ? 'Weekend' : 'Weekday';
    String temperature = 'Normal Temperature';
    String climate = 'Mist Climate';

    String formattedTime = selectedTime != null
        ? "${selectedTime!.hour.toString().padLeft(2, '0')} :34"
        : "Time not selected";

    // {'lat': 13.0148767, 'long': 80.239345, 'connection_type_4G': 1, 'isp_Airtel': 1, 'day_Saturday': 1, 'temperature': 28.53, 'climate_mist': 1, 'env_type_Free': 1, 'mobility_No movement': 1, 'floor': 0, 'movement_speed': 0.08, 'session_Morning': 1, 'day_type_Weekday': 1, 'hour': 12, 'env_Outdoor': 1}

    List<dynamic> row = [
      // time, (hh:mm) format
      // "0.0", // Placeholder for time
      formattedTime,
      lat ?? "0.0", // Latitude
      long ?? "0.0", // Longitude
      "0.0", "0.0", "0", "4G",
      selectedOperator ?? "Airtel", // ISP
      // day,
      "Saturday",
      DateTime.now().toIso8601String().split('T')[0], // Current date
      dayType, // Day type
      session, // Session
      "28.53", // Temperature
      "mist", // Climate
      "Free", // Placeholder for Free text
      "Nothing",
      "0",
      selectedMobilityStatus,
      velocity, // Velocity based on mobility status
      "", // Other fields...
      "", // Fill other empty fields with appropriate values
      "", "", "", "", "", "", "", "", "", "", "", "", "", "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
          "Outdoor", // Environment type
    ];

    print(row);

    print("clicked");
    final url = Uri.parse('http://4.186.60.228:3000/predict');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'data': row});
    print("collected data");
    print(row);

    try {
      //final response = await http.post(url, headers: headers, body: body);
      try {
        print('Data sent successfully');
        // print(response.body);
        //var data = json.decode(response.body);
        var data = predict(row);
        print("predicitions 8");
        print(data);

        double downloadSpeed = data['downloadSpeed'] != null
            ? double.tryParse(data['downloadSpeed'].toString()) ?? 0.0
            : 0.0;
        double uploadSpeed = data['uploadSpeed'] != null
            ? double.tryParse(data['uploadSpeed'].toString()) ?? 0.0
            : 0.0;
        double latency = data['latency'] != null
            ? double.tryParse(data['latency'].toString()) ?? 0.0
            : 0.0;
        double rsrp = data['rsrp'] != null
            ? double.tryParse(data['rsrp'].toString()) ?? 0.0
            : 0.0;

        String formattedDownloadSpeed = downloadSpeed.abs().toStringAsFixed(2);
        String formattedUploadSpeed = uploadSpeed.abs().toStringAsFixed(2);
        String formattedLatency = latency.abs().toStringAsFixed(2);
        String formattedRsrp = rsrp.toStringAsFixed(2);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Predicted Values',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Download Speed',
                        '$formattedDownloadSpeed Mbps', Icons.download_rounded),
                    SizedBox(height: 10),
                    _buildInfoRow('Upload Speed', '$formattedUploadSpeed Mbps',
                        Icons.upload_rounded),
                    SizedBox(height: 10),
                    _buildInfoRow(
                        'Latency', '$formattedLatency ms', Icons.timer_rounded),
                    SizedBox(height: 10),
                    _buildInfoRow('RSRP', '$formattedRsrp dbm',
                        Icons.network_cell_rounded),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Failed to send data: ${e.toString()}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

// Helper function to build each info row with an icon
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
  }

  // Time picker dialog
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Show pop-up after location and time are set
  void _showDialog() {
    if (lat != null &&
        long != null &&
        selectedTime != null &&
        selectedOperator != null &&
        selectedMobility != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location and Time Set!'),
            content: Text(
              "Location: ($lat, $long)\nTime: ${selectedTime!.format(context)}\nOperator: $selectedOperator\nMobility: $selectedMobility",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Prediction'),
        backgroundColor: const Color.fromARGB(255, 227, 238, 243),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[200]!, Colors.blueGrey[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Selected Lat and Long \n ($lat, $long)",
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                hint: Text('Select Operator'),
                value: selectedOperator,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOperator = newValue;
                  });
                },
                items: <String>['Airtel', 'Jio']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Dropdown for selecting mobility status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                hint: Text('Select Mobility Status'),
                value: selectedMobilityStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMobilityStatus = newValue;
                  });
                },
                items: <String>[
                  'No movement',
                  'Slow Walking',
                  'Walking',
                  'Running',
                  'Moving in Vehicle'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Row for Operator and Mobility Status dropdowns

            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latLng.LatLng(13.010887, 80.235406),
                  initialZoom: 17.0,
                  onLongPress: (tapPosition, point) =>
                      _handleTap(tapPosition, point),
                ),
                children: [
                  // Change from layers to children
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      if (lat != null && long != null)
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: latLng.LatLng(lat, long),
                          child: Container(
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ), // Time Picker Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.adjust,
                        color: const Color.fromARGB(255, 6, 0, 0)),
                    label: Text(
                      'Use My Current Location',
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 8, 12, 84)),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      _getCurrentLocation();
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.access_time,
                        color: const Color.fromARGB(255, 6, 0, 0)),
                    label: Text(
                      'Pick Time',
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 8, 12, 84)),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => _selectTime(context),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check,
                        color: const Color.fromARGB(255, 6, 0, 0)),
                    label: Text(
                      'Confirm',
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 8, 12, 84)),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: dataToServer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
