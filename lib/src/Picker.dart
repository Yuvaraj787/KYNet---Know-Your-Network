import 'dart:async';
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
      "", "", "", "", "", "", "", ""
      "Outdoor", // Environment type
    ];


    print(row);

    print("clicked");
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
        print("predicitions 8");
        print(data);

        double downloadSpeed = data['download_speed'] != null
            ? double.tryParse(data['download_speed'].toString()) ?? 0.0
            : 0.0;
        double uploadSpeed = data['upload_speed'] != null
            ? double.tryParse(data['upload_speed'].toString()) ?? 0.0
            : 0.0;
        double latency = data['latency'] != null
            ? double.tryParse(data['latency'].toString()) ?? 0.0
            : 0.0;
        double rsrp = data['rsrp'] != null
            ? double.tryParse(data['rsrp'].toString()) ?? 0.0
            : 0.0;

        String formattedDownloadSpeed = downloadSpeed.toStringAsFixed(2);
        String formattedUploadSpeed = uploadSpeed.toStringAsFixed(2);
        String formattedLatency = latency.toStringAsFixed(2);
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
      } else {
        print('Failed to send data: ${response.statusCode}');
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
                items: <String>['Airtel', 'Jio', 'BSNL']
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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