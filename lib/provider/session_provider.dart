import 'package:flutter/foundation.dart';
import 'package:enercle_proj/models/customer_model.dart';

class Session with ChangeNotifier {
  CustomerModel _customerInfo = CustomerModel.initialize();

  CustomerModel get customerInfo => _customerInfo;

  set setCustomerInfo(CustomerModel value) {
    _customerInfo = value;
    notifyListeners();
  }

  void flush() {
    _customerInfo = CustomerModel.initialize();
    notifyListeners();
  }

  void show() {
    print(_customerInfo.toJson());
  }
}
