import './api.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:enercle_proj/models/customer_model.dart';
import 'package:enercle_proj/models/power_realtime_model.dart';
import 'package:enercle_proj/models/power_1hour_model.dart';
import 'package:enercle_proj/models/fulfillment_history_model.dart';
import 'package:enercle_proj/models/mitigation_realtime_model.dart';

class FakeApiService implements ApiService {
  static const _jsonDir = 'assets/json/';
  static const _jsonExtension = '.json';

  @override
  Future<CustomerModel> signIn(
      String userId, String password, String phoneNum) async {
    const resourcePath = '${_jsonDir}customer_info$_jsonExtension';
    final data = await rootBundle.load(resourcePath);
    final map = json.decode(
      utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
    return CustomerModel.fromJson(map);
  }

  @override
  Future<PowerRealtimeModel> getRealtimePower(
      String customerNum, String date) async {
    const resourcePath = '${_jsonDir}last_5min_power$_jsonExtension';
    final data = await rootBundle.load(resourcePath);
    final map = json.decode(
      utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
    return PowerRealtimeModel.fromJson(map);
  }

  @override
  Future<List<Power1hourModel>> get1hourPowerCbl(
      String customerNum, String date) async {
    const resourcePath = '${_jsonDir}day_power_cbl$_jsonExtension';
    final data = await rootBundle.load(resourcePath);
    final listData = json.decode(
      utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
    return listData
        .map<Power1hourModel>(
            (dynamic element) => Power1hourModel.fromJson(element))
        .toList();
  }

  @override
  Future<List<MitigationRealtimeModel>> getRealtimeMitigation(
      String customerNum, String date) async {
    const resourcePath = '${_jsonDir}realtime_mitigation$_jsonExtension';
    final data = await rootBundle.load(resourcePath);
    final map = json.decode(
      utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
    return map
        .map<MitigationRealtimeModel>(
            (dynamic element) => MitigationRealtimeModel.fromJson(element))
        .toList();
  }

  @override
  Future<List<FulfillmentHistoryModel>> getAnnualFulfillment(
      String customerNum, String date) async {
    const resourcePath = '${_jsonDir}annual_mitigation_history$_jsonExtension';
    final data = await rootBundle.load(resourcePath);
    final listData = json.decode(
      utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
    return listData
        .map<FulfillmentHistoryModel>(
            (dynamic element) => FulfillmentHistoryModel.fromJson(element))
        .toList();
  }

  @override
  Future<String> changePassword(
      String customerNum, String password, String isAdmin) async {
    return '';
  }

  @override
  Future<String> changePeakPower(
      String customerNum, String peakPower, String isAdmin) async {
    return '';
  }

  @override
  Future<String> signOut(String userId, String phoneNum) async {
    return '';
  }
}
