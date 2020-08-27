import 'dart:math';

class HourlyStatsResponse {
  bool success;
  String message;
  List<HourlyStats> hourlyRes = List();
  HourlyStatsResponse({this.success, this.message, this.hourlyRes});


  HourlyStatsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      if (json['data']['00']['total'] != null)
        json['data'].forEach(
            (k, v) => hourlyRes.add(HourlyStats(int.tryParse(k), v['total'])));
      else if (json['data']['00']['avgFirstResponseTime'] != null)
       json['data'].forEach(
            (k, v) => hourlyRes.add(HourlyStats(int.tryParse(k), (v['avgFirstResponseTime']/1000).round()  )));
      else if (json['data']['00']['avgHandlingTime'] != null)
       json['data'].forEach(
            (k, v) => hourlyRes.add(HourlyStats(int.tryParse(k), (v['avgHandlingTime']/60000).round() )));
    }
    hourlyRes.sort((a, b) {
      return a.key - b.key;
    });
  }
}

class HourlyStats {
  int key;
  int count;
  // to add no. of tickets
  HourlyStats(this.key, this.count);
}
