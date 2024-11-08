import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<Location> {
  final Dio _dio = Dio();
  List<latLng.LatLng> locations = [
    latLng.LatLng(13.0151467, 80.2398486),
    latLng.LatLng(13.0151447, 80.2398402),
    latLng.LatLng(13.0151447, 80.2398402),
    latLng.LatLng(13.0148499, 80.2385495),
    latLng.LatLng(13.014848, 80.2384502),
    latLng.LatLng(13.0148726, 80.2384328),
    latLng.LatLng(13.0148896, 80.2384142),
    latLng.LatLng(13.0149049, 80.2383923),
    latLng.LatLng(13.0149226, 80.2383742),
    latLng.LatLng(13.0149275, 80.2383537),
    latLng.LatLng(13.0151345, 80.2379197),
    latLng.LatLng(13.0152333, 80.2376833),
    latLng.LatLng(13.0134341, 80.2362224),
    latLng.LatLng(13.0134628, 80.2359921),
    latLng.LatLng(13.0134882, 80.2359817),
    latLng.LatLng(13.013445, 80.2361883),
    latLng.LatLng(13.0134436, 80.2355255),
    latLng.LatLng(13.0134185, 80.2359906),
    latLng.LatLng(13.0134171, 80.2359884)
  ];

  var lat;
  var long;

  TimeOfDay? selectedTime;
  String? selectedOperator; // To store the selected operator
  String? selectedMobility; // To store the selected mobility status
  String? selectedEnv; // To store the selected mobility status

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

  
    void processLocation() {
      final Map<String, List<Map<String, double>>> locationCoordinates = {
        "ece_outdoor": [
          {"latitude": 13.012467062603482, "longitude": 80.23543457427367},
          {"latitude": 13.013175656224755, "longitude": 80.23573209388586},
        ],
        "KP_indoor": [
          {"latitude": 13.013663179187677, "longitude": 80.23525876722914},
          {"latitude": 13.013528488258956, "longitude": 80.23591992192287},
          {"latitude": 13.013718812376018, "longitude": 80.23522570949444},
        ],
        "vivek_audi_outdoor": [
          {"latitude": 13.011630196427927, "longitude": 80.23635988527906},
          {"latitude": 13.011591491416814, "longitude": 80.23589363954594},
        ],
        "blue_shed": [
          {"latitude": 13.013517230162423, "longitude": 80.23596398017028},
          {"latitude": 13.013713159124643, "longitude": 80.2359185154976},
        ],
        "vivekaudi_indoor": [
          {"latitude": 13.011705186658183, "longitude": 80.23599402409981},
          {"latitude": 13.011646134494056, "longitude": 80.23627282243433},
        ],
        "ground": [
          {"latitude": 13.011844558926603, "longitude": 80.23692410697093},
          {"latitude": 13.011091671944675, "longitude": 80.23671370389232},
        ],
        "IT_department_indoor": [
          {"latitude": 13.012923126494792, "longitude": 80.23593551061225},
          {"latitude": 13.012847631606677, "longitude": 80.23615955479009},
        ],
        "kp_outdoor": [
          {"latitude": 13.013450566018454, "longitude": 80.23558268226454},
          {"latitude": 13.01351801282757, "longitude": 80.23536242184568},
          {"latitude": 13.013209392429706, "longitude": 80.23572113167067},
        ],
        "red_building_indoor": [
          {"latitude": 13.01097781461135, "longitude": 80.23509972415061},
          {"latitude": 13.01104482087204, "longitude": 80.23504204452958},
        ],
        "red_building_outdoor": [
          {"latitude": 13.010871901452694, "longitude": 80.23512190862026},
          {"latitude": 13.010845963529384, "longitude": 80.23561662229304},
        ],
        "hostel_outdoor": [
          {"latitude": 13.01463002521824, "longitude": 80.23770929658207},
          {"latitude": 13.014529267618002, "longitude": 80.23824137840313},
        ],
        "hostel_indoor": [
          {"latitude": 13.014901420488535, "longitude": 80.23779936685324},
          {"latitude": 13.015206942961887, "longitude": 80.23967082702993},
        ],
        "printing_dep_outdoor": [
          {"latitude": 13.013259335970913, "longitude": 80.23514185098188},
          {"latitude": 13.013278459842335, "longitude": 80.235023270769},
        ],
        "ncc": [
          {"latitude": 13.012393848002327, "longitude": 80.23454583756933},
          {"latitude": 13.012231821269685, "longitude": 80.23466921918636},
        ],
      };

      List<latLng.LatLng> locations = [];

       locations.addAll((locationCoordinates["ncc"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));


      // Add locations based on selected operator
      if (selectedOperator == "Airtel") {

        locations.addAll((locationCoordinates["red_building_indoor"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        locations.addAll((locationCoordinates["red_building_outdoor"] ?? [])
            .map((coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        locations.addAll((locationCoordinates["hostel_outdoor"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        locations.addAll((locationCoordinates["hostel_indoor"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        locations.addAll((locationCoordinates["printing_dep_outdoor"] ?? [])
            .map((coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

      } else if (selectedOperator == "Jio") {
        locations.addAll((locationCoordinates["red_building_outdoor"] ?? [])
            .map((coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        locations.addAll((locationCoordinates["hostel_outdoor"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        locations.addAll((locationCoordinates["blue_shed"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));
      } 

      // Add location based on time (checking hour)
      try {
        int hour = int.parse(selectedTime.toString().split(":")[0]);
        if (hour >= 12) {

          locations.addAll((locationCoordinates["ece_outdoor"] ?? []).map(
              (coords) =>
                  latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));

        }
        if (hour >= 18) {
          locations.addAll((locationCoordinates["ground"] ?? []).map((coords) =>
              latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));
          locations.addAll((locationCoordinates["ncc"] ?? []).map((coords) =>
              latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));
        }
      } catch (e) {
        print("Invalid time format: $selectedTime");
      }

      if (selectedEnv == "Indoor") {

        locations.removeWhere((location) {
          return locationCoordinates.entries
              .where((entry) => entry.key.contains("outdoor"))
              .any((entry) => entry.value.any((coords) =>
                  coords['latitude'] == location.latitude &&
                  coords['longitude'] == location.longitude));
        });

      } else if (selectedEnv == "Outdoor") {

        locations.addAll((locationCoordinates["ground"] ?? []).map(
            (coords) =>
                latLng.LatLng(coords["latitude"]!, coords["longitude"]!)));
                
        locations.removeWhere((location) {
          return locationCoordinates.entries
              .where((entry) => entry.key.contains("indoor"))
              .any((entry) => entry.value.any((coords) =>
                  coords['latitude'] == location.latitude &&
                  coords['longitude'] == location.longitude));
        });
      }


      // Now, locations will contain the final list of coordinates
      setState(() {
        this.locations = locations;
      });
    }
    


  Future<void> dataToServer() async {
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

    // processTime();
    processLocation();

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

    return;

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
        title: Text('Location Prediction'),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                hint: Text('Select Environment'),
                value: selectedEnv,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEnv = newValue;
                  });
                },
                items: <String>['Indoor', 'Outdoor']
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                    icon: Icon(Icons.pin_drop,
                        color: const Color.fromARGB(255, 6, 0, 0)),
                    label: Text(
                      'Predict locations',
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
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latLng.LatLng(13.010887, 80.235406),
                  initialZoom: 17.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: List.generate(locations.length, (index) {
                      double opacity =
                          1.0 - (index * 0.08); // Gradually decreasing opacity
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: locations[index],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 23, 204, 29).withOpacity(opacity.clamp(
                                    0.2,
                                    1.0)), // Clamps the opacity between 0.2 and 1.0
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    }),
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
