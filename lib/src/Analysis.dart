import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Analysis extends StatefulWidget {
  Analysis({required this.isShowingMainData});
  bool isShowingMainData;

  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  var isShowingMainData = true;

  String? dropdownValue = "Playground CEG";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Heading
        Text(
          "Analysis",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 16), // Space between heading and dropdown

        // Dropdown Menu
        DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: <String>['Playground CEG', 'Red Building', 'Vivek Audi']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),

        SizedBox(height: 16), // Space between dropdown and chart

        // Chart Container
        Container(
          height: 400,
          padding: const EdgeInsets.only(top: 35, left: 10, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: LineChart(
            isShowingMainData ? sampleData1 : sampleData1,
            duration: const Duration(milliseconds: 250),
          ),
        ),

        // Legend
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Airtel Legend
            LegendItem(
              color: Colors.red,
              label: "Airtel",
            ),
            SizedBox(width: 20),
            // Jio Legend
            LegendItem(
              color: Color.fromARGB(255, 173, 239, 51),
              label: "Jio",
            ),
            SizedBox(width: 20),
            // BSNL Legend
            LegendItem(
              color: Color.fromARGB(255, 8, 146, 215),
              label: "BSNL",
            ),
          ],
        ),
      ],
    );
  }

  // Create LineChartData and other properties as needed

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: 0,
        maxX: 14,
        maxY: 4,
        minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        Airtel,
        Jio,
        BSNL,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text;
    switch (value.toInt()) {
      case 1:
        text = '3 Mbps';
        break;
      case 2:
        text = '10 Mbps';
        break;
      case 3:
        text = '20 Mbps';
        break;
      case 4:
        text = '50 Mbps';
        break;
      case 5:
        text = '140 Mbps';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('9:00AM', style: style);
        break;
      case 7:
        text = const Text('12:15PM', style: style);
        break;
      case 12:
        text = const Text('5:00PM', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.red, width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get Airtel => LineChartBarData(
        isCurved: true,
        color: Colors.red,
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1.1),
          FlSpot(3, 2.6),
          FlSpot(7, 1.3),
          FlSpot(10, 1.9),
          FlSpot(12, 2.4),
          FlSpot(13, 4.0),
          FlSpot(15, 2.7),
          FlSpot(17, 4.0),
          FlSpot(20, 3.1),
          FlSpot(23, 1.1),
          FlSpot(25, 3.6),
          FlSpot(27, 2.6),
          FlSpot(30, 3.2),
          FlSpot(33, 4.1),
          FlSpot(35, 3.3),
          FlSpot(37, 2.8),
          FlSpot(40, 4.3),
          FlSpot(43, 3.2),
          FlSpot(45, 1.5),
          FlSpot(47, 3.9),
          FlSpot(50, 3.0),
          FlSpot(53, 2.8),
          FlSpot(55, 11.6),
          FlSpot(57, 13.5),
          FlSpot(60, 11.6),
          FlSpot(63, 13.3),
          FlSpot(65, 11.0),
          FlSpot(67, 11.1),
          FlSpot(70, 11.8),
          FlSpot(73, 11.5),
          FlSpot(75, 12.4),
          FlSpot(77, 11.6),
          FlSpot(80, 14.3),
          FlSpot(83, 1.4),
          FlSpot(85, 2.9),
          FlSpot(87, 0.2),
          FlSpot(90, 7.8),
          FlSpot(93, 2.7),
          FlSpot(95, 3.0),
          FlSpot(97, 0.1),
          FlSpot(100, 0.4),
        ],
      );

  LineChartBarData get Jio => LineChartBarData(
        isCurved: true,
        color: const Color.fromARGB(255, 173, 239, 51),
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
          color: const Color.fromARGB(255, 27, 99, 194),
        ),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
          FlSpot(15, 2.5),
          FlSpot(17, 4.1),
          FlSpot(20, 3.0),
          FlSpot(23, 2.2),
          FlSpot(25, 3.5),
          FlSpot(27, 2.7),
          FlSpot(30, 3.1),
          FlSpot(33, 4.0),
          FlSpot(35, 3.2),
          FlSpot(37, 2.9),
          FlSpot(40, 4.2),
          FlSpot(43, 3.3),
          FlSpot(45, 2.4),
          FlSpot(47, 3.8),
          FlSpot(50, 3.1),
          FlSpot(53, 2.7),
          FlSpot(55, 4.5),
          FlSpot(57, 3.6),
          FlSpot(60, 2.5),
          FlSpot(63, 3.2),
          FlSpot(65, 4.1),
          FlSpot(67, 3.0),
          FlSpot(70, 2.9),
          FlSpot(73, 3.4),
          FlSpot(75, 2.3),
          FlSpot(77, 3.7),
          FlSpot(80, 4.4),
          FlSpot(83, 3.5),
          FlSpot(85, 2.8),
          FlSpot(87, 4.3),
          FlSpot(90, 3.9),
          FlSpot(93, 2.6),
          FlSpot(95, 3.1),
          FlSpot(97, 4.0),
          FlSpot(100, 3.3),
        ],
      );

  LineChartBarData get BSNL => LineChartBarData(
        isCurved: true,
        color: const Color.fromARGB(255, 8, 146, 215),
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 0.2),
          FlSpot(3, 0.5),
          FlSpot(7, 0.3),
          FlSpot(10, 0.6),
          FlSpot(12, 0.4),
          FlSpot(13, 0.7),
          FlSpot(15, 0.5),
          FlSpot(17, 0.8),
          FlSpot(20, 0.6),
          FlSpot(23, 0.4),
          FlSpot(25, 0.7),
          FlSpot(27, 0.5),
          FlSpot(30, 0.6),
          FlSpot(33, 0.8),
          FlSpot(35, 0.7),
          FlSpot(37, 0.5),
          FlSpot(40, 0.9),
          FlSpot(43, 0.6),
          FlSpot(45, 0.4),
          FlSpot(47, 0.7),
          FlSpot(50, 0.5),
          FlSpot(53, 0.4),
          FlSpot(55, 0.9),
          FlSpot(57, 0.7),
          FlSpot(60, 0.4),
          FlSpot(63, 0.6),
          FlSpot(65, 0.8),
          FlSpot(67, 0.5),
          FlSpot(70, 0.3),
          FlSpot(73, 0.7),
          FlSpot(75, 0.4),
          FlSpot(77, 0.8),
          FlSpot(80, 0.9),
          FlSpot(83, 0.6),
          FlSpot(85, 0.3),
          FlSpot(87, 0.8),
          FlSpot(90, 0.7),
          FlSpot(93, 0.4),
          FlSpot(95, 0.5),
          FlSpot(97, 0.8),
          FlSpot(100, 0.6),
        ],
      );
}

// Legend Item Widget
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
