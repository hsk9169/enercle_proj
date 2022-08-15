class CustomerModel {
  final String customerNumber;
  final String customerName;
  final String contractPower;
  final String cblMethod;
  String powerThreshold5;
  final String resourceCode;
  final String fcmMaxloadTitle;
  final String fcmMaxloadBody;
  final String fcmReduceTitle;
  final String fcmReduceBody;
  final String isAdmin;

  CustomerModel({
    required this.customerNumber,
    required this.customerName,
    required this.contractPower,
    required this.cblMethod,
    required this.powerThreshold5,
    required this.resourceCode,
    required this.fcmMaxloadTitle,
    required this.fcmMaxloadBody,
    required this.fcmReduceTitle,
    required this.fcmReduceBody,
    required this.isAdmin,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerNumber: json['custNo'],
      customerName: json['custName'],
      contractPower: json['contractpower'],
      cblMethod: json['CBLMethod'],
      powerThreshold5: json['powerThreshold5'] ?? 0,
      resourceCode: json['resourceCode'],
      fcmMaxloadTitle: json['mes_maxload_title'] ?? '',
      fcmMaxloadBody: json['mes_maxload_body'] ?? '',
      fcmReduceTitle: json['mes_reduce_title'] ?? '',
      fcmReduceBody: json['mes_reduce_body'] ?? '',
      isAdmin: json['usergubun'] ?? 'FALSE',
    );
  }

  factory CustomerModel.initialize() {
    return CustomerModel(
      customerNumber: '',
      customerName: '',
      contractPower: '',
      cblMethod: '',
      resourceCode: '',
      powerThreshold5: '',
      fcmMaxloadTitle: '',
      fcmMaxloadBody: '',
      fcmReduceTitle: '',
      fcmReduceBody: '',
      isAdmin: 'FALSE',
    );
  }

  Map<String, dynamic> toJson() => {
        'customerNumber': customerNumber,
        'customerName': customerName,
        'contractPower': contractPower,
        'cblMethod': cblMethod,
        'powerThreshold5': powerThreshold5,
        'resourceCode': resourceCode,
        'isAdmin': isAdmin,
      };
}
