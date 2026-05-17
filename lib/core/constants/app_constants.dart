
class AppConstants {
  AppConstants._();

  static const String appName = 'BloodLink';
  static const String appTagline = 'Donate Blood, Save Lives';

  static const String usersCollection = 'users';
  static const String requestsCollection = 'blood_requests';


  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  static const String roleDonor = 'Donor';
  static const String roleReceiver = 'Receiver';
  static const List<String> roles = [roleDonor, roleReceiver];
}
