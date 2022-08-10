abstract class ApiService {
  Future<dynamic> signIn(String userId, String password, String phoneNum);
  Future<dynamic> getRealtimePower(String customerNum, String date);
  Future<dynamic> get1hourPowerCbl(String customerNum, String date);
  Future<dynamic> getRealtimeMitigation(String customerNum, String date);
  Future<dynamic> getAnnualFulfillment(String customerNum, String date);
  Future<dynamic> changePassword(
      String customerNum, String password, String isAdmin);
  Future<dynamic> changePeakPower(
      String customerNum, String peakPower, String isAdmin);
}
