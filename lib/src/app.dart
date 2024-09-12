import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KyNet Data Collection Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('KyNet Data Collection Tool'),
        ),
        body: Center(
          child: TimeButton(),
        ),
      ),
    );
  }
}

class TimeButton extends StatefulWidget {
  @override
  _TimeButtonState createState() => _TimeButtonState();
}

class _TimeButtonState extends State<TimeButton> {
  Map<String, String> _parameters = {};

  String _environmentType = 'crowded';
  String _location = 'A';
  String _environment = 'indoor';
  String _floor = '0';
  String _uploadSpeed = 'N/A';
  String _downloadSpeed = 'N/A';

  @override
  void initState() {
    super.initState();
    _updateParameters(); // Perform initial parameter update
  }

  Future<void> _updateParameters() async {
    // Perform the speed test
    await _performSpeedTest();

    setState(() {
      _parameters = {
        'RSSI': _getRSSI(),
        'RSRP': _getRSRP(),
        'RSRQ': _getRSRQ(),
        'SINR': _getSINR(),
        'RF-NC': _getRFNC(),
        'p-a': _getPA(),
        'Band': _getBand(),
        'Num Carriers': _getNumCarriers(),
        'RSPath Loss': _getRSPathLoss(),
        'TA': _getTA(),
        'Shannon': _getShannon(),
        'CellLoad': _getCellLoad(),
        'RF-RX0': _getRFRX0(),
        'RF-RX1': _getRFRX1(),
        'RF-RX2': _getRFRX2(),
        'RF-RX3': _getRFRX3(),
        'RI sum': _getRISum(),
        'CQI': _getCQI(),
        'CRI': _getCRI(),
        'Time': DateTime.now().toString(),
        'DAY': _getDay(),
        'TYPE OF DAY': _getTypeOfDay(),
        'INTERNET SERVICE PROVIDER': _getISP(),
        'SIGNAL STRENGTH': _getSignalStrength(),
        'INTERNET UPLOAD SPEED': _uploadSpeed,
        'INTERNET DOWNLOAD SPEED': _downloadSpeed,
        'NETWORK TYPE': _getNetworkType(),
        'ENVIRONMENT TYPE': _environmentType,
        'LATENCY': _getLatency(),
        'LOCATION NAME': _location,
        'LATITUDE': _getLatitude(),
        'LONGITUDE': _getLongitude(),
        'ENVIRONMENT': _environment,
        'WEATHER': _getWeather(),
        'TIME PERIOD': _getTimePeriod(),
        'FLOOR': _floor,
      };
      _sendParametersToDatabase(_parameters);
    });
  }

  Future<void> _performSpeedTest() async {
    try {
      final client = SpeedTestDart();

      // Get settings, which includes the list of available servers
      final settings = await client.getSettings();
      final servers = settings.servers; // List of available servers

      // Perform the download speed test using the list of servers
      final downloadResult = await client.testDownloadSpeed(
        servers: servers,
      );

      // Perform the upload speed test using the list of servers
      final uploadResult = await client.testUploadSpeed(
        servers: servers,
      );

      // Update the state with the results
      setState(() {
        _downloadSpeed = '${downloadResult.toStringAsFixed(2)} Mbps';
        _uploadSpeed = '${uploadResult.toStringAsFixed(2)} Mbps';
      });
    } catch (e) {
      print('Speed test failed: $e');
      setState(() {
        _downloadSpeed = 'Failed';
        _uploadSpeed = 'Failed';
      });
    }
  }

  void _sendParametersToDatabase(Map<String, String> parameters) {
    // Implement your database sending logic here
    print('Sending parameters to database: $parameters');
  }

  
  String _getRSSI() => 'RSSI Value'; 
  String _getRSRP() => 'RSRP Value'; 
  String _getRSRQ() => 'RSRQ Value'; 
  String _getSINR() => 'SINR Value'; 
  String _getRFNC() => 'RF-NC Value'; 
  String _getPA() => 'p-a Value'; 
  String _getBand() => 'Band Value'; 
  String _getNumCarriers() => 'Num Carriers Value'; 
  String _getRSPathLoss() => 'RSPath Loss Value';
  String _getTA() => 'TA Value'; 
  String _getShannon() => 'Shannon Value'; 
  String _getCellLoad() => 'CellLoad Value'; 
  String _getRFRX0() => 'RF-RX0 Value'; 
  String _getRFRX1() => 'RF-RX1 Value';
  String _getRFRX2() => 'RF-RX2 Value';
  String _getRFRX3() => 'RF-RX3 Value'; 
  String _getRISum() => 'RI sum Value'; 
  String _getCQI() => 'CQI Value'; 
  String _getCRI() => 'CRI Value'; 
  String _getDay() => 'Day Value'; 
  String _getTypeOfDay() => 'Type of Day Value'; 
  String _getISP() => 'ISP Value'; 
  String _getSignalStrength() => 'Signal Strength Value'; 
  String _getNetworkType() => 'Network Type Value'; 
  String _getLatency() => 'Latency Value'; 
  String _getLatitude() => 'Latitude Value'; 
  String _getLongitude() => 'Longitude Value'; 
  String _getWeather() => 'Weather Value'; 
  String _getTimePeriod() => 'Time Period Value'; 
  String _getFloor() => 'Floor Value'; 

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: _environmentType,
          onChanged: (String? newValue) {
            setState(() {
              _environmentType = newValue!;
            });
          },
          items: <String>['crowded', 'free']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        DropdownButton<String>(
          value: _location,
          onChanged: (String? newValue) {
            setState(() {
              _location = newValue!;
            });
          },
          items: <String>['A', 'B', 'C', 'D', 'E']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        DropdownButton<String>(
          value: _environment,
          onChanged: (String? newValue) {
            setState(() {
              _environment = newValue!;
            });
          },
          items: <String>['indoor', 'outdoor']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        DropdownButton<String>(
          value: _floor,
          onChanged: (String? newValue) {
            setState(() {
              _floor = newValue!;
            });
          },
          items: <String>['0', '1', '2', '3', '4', '5']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: _updateParameters,
          child: Text('Test now'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _parameters.length,
            itemBuilder: (context, index) {
              String key = _parameters.keys.elementAt(index);
              return ListTile(
                title: Text('$key: ${_parameters[key]}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
