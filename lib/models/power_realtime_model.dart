class PowerRealtimeModel {
  final String date;
  final String time;
  final String powerLast5min;
  final String powerYesterday5min;
  final String powerLastSum;
  final String powerYesterdaySum;

  PowerRealtimeModel(
      {required this.date,
      required this.time,
      required this.powerLast5min,
      required this.powerYesterday5min,
      required this.powerLastSum,
      required this.powerYesterdaySum});

  factory PowerRealtimeModel.fromJson(Map<String, dynamic> json) {
    return PowerRealtimeModel(
        date: json['mr_ymd'],
        time: json['hhmi'],
        powerLast5min: json['pwr_qty_5'],
        powerYesterday5min: json['pwr_qty_yester5'],
        powerLastSum: json['pwr_qty_sum'],
        powerYesterdaySum: json['pwr_qty_yesterSum']);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'powerLast5min': powerLast5min,
        'powerYesterday5min': powerYesterday5min,
        'powerLastSum': powerLastSum,
        'powerYesterdaySum': powerYesterdaySum,
      };
}
