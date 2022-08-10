class RealtimeData {
  final int hour;
  final double power;

  RealtimeData({required this.hour, required this.power});
}

class FulfillmentData {
  final String cat;
  final double fulfillment;

  FulfillmentData({required this.cat, required this.fulfillment});
}

class FulfillRateData {
  final String cat;
  final int rate;

  FulfillRateData({required this.cat, required this.rate});
}
