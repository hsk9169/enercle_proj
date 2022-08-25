import 'dart:async';
import 'dart:io';

import 'package:enercle_proj/models/fulfillment_history_model.dart';
import './api.dart';
import 'dart:convert';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:enercle_proj/models/customer_model.dart';
import 'package:enercle_proj/models/power_realtime_model.dart';
import 'package:enercle_proj/models/power_1hour_model.dart';
import 'package:enercle_proj/models/mitigation_realtime_model.dart';

class RealApiService implements ApiService {
  //final _hostAddress = dotenv.env['HOST_ADDRESS'];
  final _hostAddress = '112.220.98.19';

  @override
  Future<dynamic> signIn(
      String userId, String password, String phoneNum) async {
    try {
      final res = await http.post(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              //path: dotenv.env['API_SIGNIN']),
              path: '/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(<String, String>{
            'UserID': userId,
            'pwd': password,
            'UserPhone': phoneNum,
          }));
      if (res.statusCode == 201) {
        return CustomerModel.fromJson(jsonDecode(res.body));
      } else if (res.statusCode == 400 ||
          res.statusCode == 401 ||
          res.statusCode == 402) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> getRealtimePower(String customerNum, String date) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              //path: dotenv.env['API_GET_LAST_5MIN_POWER'],
              path: '/realtimedata',
              queryParameters: {
                'custNo': customerNum,
                'mr_ymd': date,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      if (res.statusCode == 201 || res.statusCode == 203) {
        return PowerRealtimeModel.fromJson(jsonDecode(res.body));
      } else if (res.statusCode == 202) {
        return 'NO_DATA';
      } else if (res.statusCode == 400 || res.statusCode == 401) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> get1hourPowerCbl(String customerNum, String date) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              //path: dotenv.env['API_GET_1HOUR_POWER_CBL'],
              path: '/lpdataAll',
              queryParameters: {
                'custNo': customerNum,
                'mr_ymd': date,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body)
            .map<Power1hourModel>(
                (dynamic element) => Power1hourModel.fromJson(element))
            .toList();
      } else if (res.statusCode == 202) {
        return 'NO_DATA';
      } else if (res.statusCode == 400 || res.statusCode == 401) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> getRealtimeMitigation(String customerNum, String date) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              //path: dotenv.env['API_GET_ANNUAL_FULFILLMENT'],
              path: '/reduceinfo',
              queryParameters: {
                'custNo': customerNum,
                'mr_ymd': date,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      if (res.statusCode == 201 || res.statusCode == 203) {
        return jsonDecode(res.body)
            .map((element) => MitigationRealtimeModel.fromJson(element))
            .toList();
      } else if (res.statusCode == 202) {
        return 'NO_DATA';
      } else if (res.statusCode == 400 || res.statusCode == 401) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> getAnnualFulfillment(String customerNum, String date) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              //path: dotenv.env['API_GET_ANNUAL_FULFILLMENT'],
              path: '/pastreduceinfo',
              queryParameters: {
                'custNo': customerNum,
                'year': date,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      if (res.statusCode == 201 || res.statusCode == 203) {
        return jsonDecode(res.body)
            .map<FulfillmentHistoryModel>(
                (dynamic element) => FulfillmentHistoryModel.fromJson(element))
            .toList();
      } else if (res.statusCode == 202) {
        return 'NO_DATA';
      } else if (res.statusCode == 400 || res.statusCode == 401) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<String> changePassword(
      String customerNum, String password, String isAdmin) async {
    try {
      final res = await http.post(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              //path: dotenv.env['API_SIGNIN']),
              path: '/pwdupdate'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(<String, String>{
            'UserID': customerNum,
            'pwd': password,
            'usergubun': isAdmin,
          }));
      if (res.statusCode == 201) {
        return '';
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<String> changePeakPower(
      String customerNum, String peakPower, String isAdmin) async {
    try {
      final res = await http.post(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              port: 6161,
              path: '/maxloadupdate'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(<String, String>{
            'UserID': customerNum,
            'powerThreshold5': peakPower.toString(),
            'usergubun': isAdmin,
          }));
      if (res.statusCode == 201) {
        return '';
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<String> signOut(String userId, String phoneNum) async {
    try {
      final res = await http.post(
          Uri(scheme: 'http', host: _hostAddress, port: 6161, path: '/logout'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(<String, String>{
            'UserID': userId,
            'UserPhone': phoneNum,
          }));
      if (res.statusCode == 201) {
        return '';
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        return 'BAD_REQUEST';
      } else {
        return 'SERVER_ERROR';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }
}
