import 'package:url_launcher/url_launcher.dart';

class PatientLogic {
  static Future<void> openMap(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
