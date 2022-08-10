class PowerTotalModel {
  final String customerNumber;
  final String date;
  final double powerTotal;
  final String sensorNumber;

  PowerTotalModel(
      {required this.customerNumber,
      required this.date,
      required this.powerTotal,
      required this.sensorNumber});

  factory PowerTotalModel.fromJson(Map<String, dynamic> json) {
    return PowerTotalModel(
      customerNumber: json['custNo'],
      date: json['mr_ymd'],
      powerTotal: json['pwr_total'],
      sensorNumber: json['SensorNo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'customerNumber': customerNumber,
        'date': date,
        'powerTotal': powerTotal.toString(),
        'sensorNumber': sensorNumber,
      };
}
