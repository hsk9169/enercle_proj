class MitigationRealtimeModel {
  final String state;
  final String date;
  final String startTime;
  final String endTime;
  final String type;
  final String cbl;
  final String mitigationTotal;
  final String mitigationExpect;
  final String fulfillmentExpect;
  final String time;
  final String contractPower;

  MitigationRealtimeModel({
    required this.state,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.cbl,
    required this.mitigationTotal,
    required this.mitigationExpect,
    required this.fulfillmentExpect,
    required this.time,
    required this.contractPower,
  });

  factory MitigationRealtimeModel.fromJson(Map<String, dynamic> json) {
    return MitigationRealtimeModel(
        state: json['state'],
        date: json['ReduceDay'],
        startTime: json['ReduceStartTime'],
        endTime: json['ReduceEndTime'],
        type: json['Gubun'] == 'entertest'
            ? '등록시험'
            : json['Gubun'] == 'reducetest'
                ? '감축시험'
                : json['Gubun'] == 'emergency'
                    ? '감축발령'
                    : json['Gubun'] == 'voluntarily'
                        ? '자발적DR'
                        : '알 수 없음',
        cbl: json['ThatCBL'],
        mitigationTotal: json['ReducePwr'],
        mitigationExpect: json['PreReducePwr'],
        fulfillmentExpect: json['ResultPercenet'] ?? '0',
        time: json['hhmi'],
        contractPower: json['ContractPower'] ?? '0');
  }

  factory MitigationRealtimeModel.reset() {
    return MitigationRealtimeModel(
        state: 'far',
        date: '',
        startTime: '',
        endTime: '',
        type: '',
        cbl: '',
        mitigationTotal: '',
        mitigationExpect: '',
        fulfillmentExpect: '',
        time: '',
        contractPower: '');
  }
}
