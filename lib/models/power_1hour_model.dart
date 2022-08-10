class Power1hourModel {
  final String date;
  final String time;
  //final String power1hour;
  //final String cbl;
  final double power1hour;
  final double cbl;

  Power1hourModel(
      {required this.date,
      required this.time,
      required this.power1hour,
      required this.cbl});

  factory Power1hourModel.fromJson(Map<String, dynamic> json) {
    return Power1hourModel(
      date: json['mr_ymd'],
      time: json['hhmi'],
      power1hour: json['pwr_qty'],
      cbl: json['CBL'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'power1hour': power1hour,
        'cbl': cbl,
      };
}