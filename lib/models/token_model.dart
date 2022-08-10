class TokenModel {
  late String? accessToken;
  late String? refreshToken;

  TokenModel({this.accessToken, this.refreshToken});

  TokenModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    accessToken = token['accessToken'];
    refreshToken = token['refreshToken'];
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
