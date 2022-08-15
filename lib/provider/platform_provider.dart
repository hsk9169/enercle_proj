import 'package:flutter/foundation.dart';

class Platform with ChangeNotifier {
  bool _isLoading = false;
  bool _isMitigating = false;
  DateTime _mitigationTime = DateTime.now();
  String _mitigationType = '';
  String _id = '';
  String _pw = '';
  String _phoneNum = '';
  bool _idSaved = false;
  bool _phoneNumSaved = false;
  bool _autoSignin = false;
  int _mitigationBadgeCount = 0;
  int _peakBadgeCount = 0;
  int _totalBadgeCount = 0;
  int _servicePageNum = 0;
  bool _allowAlarm = true;
  bool _isErrorMessagePopup = false;
  String _popupErrorMessage = '';
  bool _isSignedOut = false;

  bool get isLoading => _isLoading;
  bool get isMitigating => _isMitigating;
  DateTime get mitigationTime => _mitigationTime;
  String get mitigationType => _mitigationType;
  String get id => _id;
  String get pw => _pw;
  String get phoneNum => _phoneNum;
  bool get idSaved => _idSaved;
  bool get phoneNumSaved => _phoneNumSaved;
  bool get autoSignin => _autoSignin;
  int get mitigationBadgeCount => _mitigationBadgeCount;
  int get peakBadgeCount => _peakBadgeCount;
  int get totalBadgeCount => _totalBadgeCount;
  int get servicePageNum => _servicePageNum;
  bool get allowAlarm => _allowAlarm;
  bool get isErrorMessagePopup => _isErrorMessagePopup;
  String get popupErrorMessage => _popupErrorMessage;
  bool get isSignedOut => _isSignedOut;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set isMitigating(bool value) {
    _isMitigating = value;
    notifyListeners();
  }

  set mitigationTime(DateTime value) {
    _mitigationTime = value;
    notifyListeners();
  }

  set mitigationType(String value) {
    _mitigationType = value;
    notifyListeners();
  }

  set userId(String value) {
    _id = value;
    notifyListeners();
  }

  set userPw(String value) {
    _pw = value;
    notifyListeners();
  }

  set userPhoneNum(String value) {
    _phoneNum = value;
    notifyListeners();
  }

  set idSaved(bool value) {
    _idSaved = value;
    notifyListeners();
  }

  set phoneNumSaved(bool value) {
    _phoneNumSaved = value;
    notifyListeners();
  }

  set autoSignin(bool value) {
    _autoSignin = value;
    notifyListeners();
  }

  void addMitigationBadgeCount() {
    _mitigationBadgeCount++;
    calculateBadgeCount();
  }

  void resetMitigationBadgeCount() {
    _mitigationBadgeCount = 0;
    calculateBadgeCount();
  }

  void addPeakBadgeCount() {
    _peakBadgeCount++;
    calculateBadgeCount();
  }

  void resetPeakBadgeCount() {
    _peakBadgeCount = 0;
    calculateBadgeCount();
  }

  void calculateBadgeCount() {
    _totalBadgeCount = _mitigationBadgeCount + _peakBadgeCount;
    notifyListeners();
  }

  set servicePageNum(int value) {
    _servicePageNum = value;
    notifyListeners();
  }

  set allowAlarm(bool value) {
    _allowAlarm = value;
    notifyListeners();
  }

  set isErrorMessagePopup(bool value) {
    _isErrorMessagePopup = value;
    notifyListeners();
  }

  set popupErrorMessage(String value) {
    _popupErrorMessage = value;
    notifyListeners();
  }

  set isSignedOut(bool value) {
    _isSignedOut = value;
    notifyListeners();
  }

  void flush() {
    _isLoading = false;
    _isMitigating = false;
    _mitigationTime = DateTime.now();
    _mitigationType = '';
    _mitigationBadgeCount = 0;
    _peakBadgeCount = 0;
    _totalBadgeCount = 0;
    _servicePageNum = 0;
    _isErrorMessagePopup = false;
    _popupErrorMessage = '';
    _isSignedOut = true;
    notifyListeners();
  }

  void show() {
    print('id: $_id');
    print('pw: $_pw');
    print('idSaved: $_idSaved');
    print('autoSignin: $_autoSignin');
  }
}

class RemainTime {
  int min;
  int sec;

  RemainTime({required this.min, required this.sec});
}
