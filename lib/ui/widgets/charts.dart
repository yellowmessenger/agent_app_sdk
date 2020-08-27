import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'chartsample.dart';

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleLineChart(this.seriesList, {this.animate});

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData() {
    return new SimpleLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    LineChartBarData chart;
    List<FlSpot> spotsList = List<FlSpot>();

    for (var i = 0; i < seriesList[0].data.length; i++) {
      spotsList.add(FlSpot(i + .0, seriesList[0].data[i].count + .0));
    }

    chart = LineChartBarData(
      preventCurveOverShooting: true,
      spots: spotsList,
      isCurved: true,
      colors: gradientColors,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );

    return LineChart(
      sampleData(chart),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
    // return  ChartSample();
  }

  LineChartData sampleData(LineChartBarData chartData) {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '12 AM';

              case 5:
                return '06 AM';

              case 11:
                return '12 PM';

              case 17:
                return '6 PM';

              case 22:
                return '11 PM';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1';
              case 3:
                return '3';
              case 5:
                return '5';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: max(1, getMax(chartData.spots)-1),
      lineBarsData: [
        chartData,
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    Random random = Random();
    final data = [
      LinearSales(1, random.nextInt(20) * 5),
      LinearSales(2, random.nextInt(20) * 5),
      LinearSales(3, random.nextInt(20) * 5),
      LinearSales(4, random.nextInt(20) * 5),
      LinearSales(5, random.nextInt(20) * 5),
      LinearSales(6, random.nextInt(20) * 5),
      LinearSales(7, random.nextInt(20) * 5),
    ];

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  double getMax(List<FlSpot> spots) {
    var maxVal = 0.0;
    for (var item in spots) {
      maxVal = max(maxVal, item.y);
    }
    return maxVal;
  }
  int closestNumber(double n, double m) 
    { 
        // find the quotient 
        int q = n ~/ m; 
           
        // 1st possible closest number 
        int n1 = (m * q).toInt(); 
           
        // 2nd possible closest number 
        int n2 =( (n * m) > 0 ? (m * (q + 1)) : (m * (q - 1))).toInt(); 
           
        // if true, then n1 is the required closest number 
        if ( (n - n1) < (n - n2)) 
            return n1; 
           
        // else n2 is the required closest number     
        return n2;     
    } 
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
