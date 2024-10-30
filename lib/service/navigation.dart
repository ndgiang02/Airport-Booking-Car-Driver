
import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

void openMaps({
  required LatLng pickup,
  required LatLng destination,
  List<LatLng>? stops,
}) async {

  String url = 'https://www.google.com/maps/dir/?api=1&origin=${pickup.latitude},${pickup.longitude}';

  if (stops != null && stops.isNotEmpty) {
    String waypoints = stops.map((stop) => '${stop.latitude},${stop.longitude}').join('|');
    url += '&waypoints=$waypoints';
  }

  url += '&destination=${destination.latitude},${destination.longitude}&travelmode=driving';

  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    log('Could not launch $url');
  }
}
