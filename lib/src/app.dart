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

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KyNet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('KYNet Data Collection Tool'),
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
  String _location = 'IT Dept';
  String _environment = 'indoor';
  String _lat = '';
  String _longi = '';
  String _floor = '0';

  void _updateParameters() async {
    String isp = await _getISP();
    String weather = await _getWeather();
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
        'INTERNET SERVICE PROVIDER': isp,
        'SIGNAL STRENGTH': _getSignalStrength(),
        'INTERNET UPLOAD SPEED': _getUploadSpeed(),
        'INTERNET DOWNLOAD SPEED': _getDownloadSpeed(),
        'NETWORK TYPE': _getNetworkType(),
        'ENVIRONMENT TYPE': _environmentType,
        'LATENCY': _getLatency(),
        'LOCATION NAME': _location,
        'LATITUDE': _lat,
        'LONGITUDE': _longi,
        'ENVIRONMENT': _environment,
        'WEATHER': weather,
        'TIME PERIOD': _getTimePeriod(),
        'FLOOR': _floor,
      };
      _sendParametersToDatabase(_parameters);
    });
  }

  Future<String> _getISP() async {
    // Get the current connectivity status
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return 'No internet connection';
    }

    // Use a third-party API to get ISP information based on IP address
    final response = await http.get(Uri.parse('https://ipinfo.io/json'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['org'] ?? 'Unknown ISP';
    } else {
      return 'Failed to get ISP information';
    }
  }

  void _sendParametersToDatabase(Map<String, String> parameters) {
    // Implement your database sending logic here
    print('Sending parameters to database: $parameters');
  }

  Future<double> _getLongitude() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    print(position.longitude);

    setState(() {
      _longi = position.longitude.toString();
      _lat = position.latitude.toString();
    });

    return position.longitude;
  }

  // Placeholder methods for data retrieval logic
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
  String _getDay() {
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    _getLongitude();
    return days[DateTime.now().weekday - 1];
  }

  String _getTypeOfDay() {
    int day = DateTime.now().weekday;
    return (day == DateTime.saturday || day == DateTime.sunday)
        ? 'weekend'
        : 'weekday';
  }

  String _getTimePeriod() {
    int hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  String _getSignalStrength() => 'Signal Strength Value';
  String _getUploadSpeed() => 'Upload Speed Value';
  String _getDownloadSpeed() => 'Download Speed Value';
  String _getNetworkType() => 'Network Type Value';
  String _getLatency() => 'Latency Value';

  Future<String> _getWeather() async {
    if (_lat.isEmpty || _longi.isEmpty) {
      await _getLongitude();
    }
    const apiKey = 'cd908d976e0a1eed6e522b5af2bf5ab7';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_longi&appid=$apiKey&units=metric';

    // Debug prints
    print('Fetching weather for lat: $_lat, lon: $_longi');
    print('Request URL: $url');

    final response = await http.get(Uri.parse(url));

    // Debug prints
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['weather'][0]['description'] ?? 'Unknown weather';
    } else {
      return 'Failed to get weather information';
    }
  }

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
          items: <String>['IT Dept', 'Kp', 'INDIA', 'Thailand', 'Vivek Audi']
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
                title: Text('$key:- ${_parameters[key]}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
