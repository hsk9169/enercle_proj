class FulfillmentHistoryModel {
  final String date;
  final String startTime;
  final String endTime;
  final String type;
  final String cbl;
  final String mitigationPower;
  final String power;
  final String fulfillmentRate;
  final String contractPower;

  FulfillmentHistoryModel({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.cbl,
    required this.mitigationPower,
    required this.power,
    required this.fulfillmentRate,
    required this.contractPower,
  });

  factory FulfillmentHistoryModel.fromJson(Map<String, dynamic> json) {
    return FulfillmentHistoryModel(
        date: json['ReduceDay'] ?? 'Null',
        startTime: json['ReduceStartTime'] ?? 'Null',
        endTime: json['ReduceEndTime'] ?? 'Null',
        type: json['Gubun'] == 'entertest'
            ? '등록'
            : json['Gubun'] == 'reducetest'
                ? '감축'
                : json['Gubun'] == 'emergency'
                    ? '발령'
                    : json['Gubun'] == 'voluntarily'
                        ? '자발적'
                        : 'Null',
        cbl: json['ThatCBL'] ?? '0',
        mitigationPower: json['ReducePwr'] ?? '0',
        power: json['Pwr'] ?? '0',
        fulfillmentRate: json['ResultPercent'] ?? '0',
        contractPower: json['ContractPower'] ?? '0');
  }
}
