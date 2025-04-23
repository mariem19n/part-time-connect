import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../auth_helper.dart';

class LocationService {
  static Future<bool> updatePreferredLocations(List<String> locations) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/update-location/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({'locations': locations}),
      );

      if (response.statusCode == 200) {
        print('Locations updated successfully');
        return true;
      } else {
        print('Failed to update locations: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating locations: $e');
      return false;
    }
  }

  static Future<bool> updateMapLocations(List<LatLng> locations) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found');
        return false;
      }

      // Convert LatLng to address strings
      List<String> locationStrings = [];
      for (var location in locations) {
        try {
          final placemarks = await placemarkFromCoordinates(
              location.latitude,
              location.longitude
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            locationStrings.add(
                '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'
                    .replaceAll(RegExp(r', , '), ', ')
                    .replaceAll(RegExp(r', $'), '')
            );
          } else {
            locationStrings.add('${location.latitude}, ${location.longitude}');
          }
        } catch (e) {
          print('Error converting location: $e');
          locationStrings.add('${location.latitude}, ${location.longitude}');
        }
      }

      return await updatePreferredLocations(locationStrings);
    } catch (e) {
      print('Error converting locations: $e');
      return false;
    }
  }
}