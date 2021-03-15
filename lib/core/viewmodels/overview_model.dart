import 'dart:async';
import 'dart:math';

import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/resolved_list.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/debounce.dart';
import 'package:support_agent/locator.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'base_model.dart';

class OverViewModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  Api _api = locator<Api>();
  BotService _botService = locator<BotService>(); // For current Bot
  final _debouncer = Debouncer(milliseconds: 1500);
  Timer timer;

  String onlineUsers = "0";
  String onlineAgents = "0";
  String busyAgents = "0";
  String allAvailableAgents = "0";
  String activeTickets = "0";
  int resolvedTicketsCount = 0;
  int avgHandlingTime = 0;
  int firstResponseTime = 0;
  List<HourlyStats> resolvedList = List<HourlyStats>();
  List<HourlyStats> weeklyResolvedList = List<HourlyStats>();
  List<HourlyStats> monthlyResolvedList = List<HourlyStats>();
  List<HourlyStats> avgHandlingTimeList = List<HourlyStats>();
  List<HourlyStats> weeklyAvgHandlingTimeList = List<HourlyStats>();
  List<HourlyStats> monthlyAvgHandlingTimeList = List<HourlyStats>();
  List<HourlyStats> firstResponseTimeList = List<HourlyStats>();
  List<HourlyStats> weeklyFirstResponseTimeList = List<HourlyStats>();
  List<HourlyStats> monthlyFirstResponseTimeList = List<HourlyStats>();
  List<charts.Series<HourlyStats, int>> resolutionResponseChart = List();
  List<charts.Series<HourlyStats, int>> avgHandlingTimeChart = List();
  List<charts.Series<HourlyStats, int>> firstResponseTimeChart = List();

  List<charts.Series<HourlyStats, int>> weeklyResolutionResponseChart = List();
  List<charts.Series<HourlyStats, int>> weeklyAvgHandlingTimeChart = List();
  List<charts.Series<HourlyStats, int>> weeklyFirstResponseTimeChart = List();

  List<charts.Series<HourlyStats, int>> monthlyResolutionResponseChart = List();
  List<charts.Series<HourlyStats, int>> monthlyAvgHandlingTimeChart = List();
  List<charts.Series<HourlyStats, int>> monthlyFirstResponseTimeChart = List();

  initOverview() {
    setState(ViewState.Busy);
    var authToken = _authenticationService.currentUserData.accessToken;
    var botId = _botService.defaultBot.userName;

    //get realtime stats.
    getRealTimeStats(authToken, botId); // for initial data
    timer = Timer.periodic(
        Duration(seconds: 60),
        (Timer t) => _debouncer.run(() async {
              try {
                await getRealTimeStats(authToken, botId);
              } catch (e) {}
            }));

    try {
      getTodaySummary(authToken, botId);
    } catch (e) {
      // print('heree: $e');
    }

    //get week stats.
    // getWeekStats(authToken , botId);
    //get month stats.
    // getMonthStats(authToken);
    setState(ViewState.Idle);
  }

  getRealTimeStats(String authToken, String botId) async {
    var currentUserCount = await _api.getCurrentUsersStats(authToken, botId);
    var activeTicket = await _api.getActiveTicketStats(authToken, botId);
    var availableAgents =
        await _api.getAgentAvailabilityStats(authToken, botId);
    setState(ViewState.Busy);
    onlineUsers = currentUserCount.data.toString() ?? "0";
    activeTickets = activeTicket.data["count"].toString() ?? "0";
    int onlineCount = 0, busyCount = 0;
    for (var item in availableAgents.data) {
      if (item['status'] == 'available')
        onlineCount++;
      else if (item['status'] == 'dnd') busyCount++;
    }
    busyAgents = busyCount.toString() ?? "0";
    onlineAgents = onlineCount.toString() ?? "0";
    allAvailableAgents = (busyCount + onlineCount).toString() ?? "0";
    setState(ViewState.Idle);
  }

  getTodaySummary(String authToken, String botId) async {
    Map<String, dynamic> hourlyResolutionFilter;
    hourlyResolutionFilter = {
      'index': "resolved_count",
      'summaryType': "today",
      'timezone': "Asia/Calcutta"
    };

    Map<String, dynamic> hourlyAvgTimeFilter;
    hourlyAvgTimeFilter = {
      'index': "average_handling_time",
      'summaryType': "today",
      'timezone': "Asia/Calcutta"
    };

    Map<String, dynamic> hourlyFirstResponseTimeFilter;
    hourlyFirstResponseTimeFilter = {
      'index': "first_response_time",
      'summaryType': "today",
      'timezone': "Asia/Calcutta"
    };

    var reolutionResponse =
        await _api.getSummary(authToken, botId, hourlyResolutionFilter);
    var handlingTimeResponse =
        await _api.getSummary(authToken, botId, hourlyAvgTimeFilter);
    var firstResponseTimeResponse =
        await _api.getSummary(authToken, botId, hourlyFirstResponseTimeFilter);

    setState(ViewState.Busy);
    resolvedList = reolutionResponse.hourlyRes;
    resolutionResponseChart = [
      charts.Series<HourlyStats, int>(
          data: resolvedList,
          id: 'Resolved Today',
          domainFn: (HourlyStats datum, int index) => datum.key,
          measureFn: (HourlyStats datum, int index) => datum.count)
    ];

    avgHandlingTimeList = handlingTimeResponse.hourlyRes;
    avgHandlingTimeChart = [
      charts.Series<HourlyStats, int>(
          data: avgHandlingTimeList,
          id: 'Avg Handling Time Today',
          domainFn: (HourlyStats datum, int index) => datum.key,
          measureFn: (HourlyStats datum, int index) => datum.count)
    ];

    firstResponseTimeList = firstResponseTimeResponse.hourlyRes;
    firstResponseTimeChart = [
      charts.Series<HourlyStats, int>(
          data: firstResponseTimeList,
          id: 'First Response Time Today',
          domainFn: (HourlyStats datum, int index) => datum.key,
          measureFn: (HourlyStats datum, int index) => datum.count)
    ];

    setState(ViewState.Idle);
  }

  getWeekStats(String authToken, String botId) async {
    Map<String, dynamic> weeklyResolvedFilter;
    weeklyResolvedFilter = {
      'index': "resolved_count",
      'summaryType': "last_seven",
      'timezone': "Asia/Calcutta"
    };
    var reolutionResponse =
        await _api.getSummary(authToken, botId, weeklyResolvedFilter);
    setState(ViewState.Busy);
    weeklyResolvedList = reolutionResponse.hourlyRes;
    weeklyResolutionResponseChart = [
      charts.Series<HourlyStats, int>(
          data: weeklyResolvedList,
          id: 'Resolved Weekly',
          domainFn: (HourlyStats datum, int index) => datum.key,
          measureFn: (HourlyStats datum, int index) => datum.count)
    ];
    setState(ViewState.Idle);
  }

  getMonthStats(String authToken) {}

  getResolvedTicketCount() {
    int count = 0;
    if (resolvedList.length == 24)
      resolvedList.forEach((f) => count += f.count);
    return count.toString();
  }

  getFirstResponseAvg() {
    int minTime = 0;
    if (firstResponseTimeList.length == 24)
      firstResponseTimeList.forEach((f) => minTime = max(minTime, f.count));

    return minTime.toString();
  }

  getAvgHandlingTime() {
    int count = 0;
    int hourActiveCount = 0;
    if (avgHandlingTimeList.length == 24)
      avgHandlingTimeList.forEach((f) {
        if (f.count != 0) {
          count += f.count;
          hourActiveCount++;
        }
      });
    try {
      return (count / hourActiveCount).round().toString();
    } catch (e) {
      print(e);
    }
  }
}
