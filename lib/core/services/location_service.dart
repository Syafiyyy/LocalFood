import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get the current position with permission handling
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, try again
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return null;
    } 

    // When we reach here, permissions are granted
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Get human-readable address from coordinates
  static Future<String> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
        localeIdentifier: 'en_MY', // Use Malaysia locale when possible
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // For debugging
        debugPrint('LOCATION DATA: ${place.locality}, ${place.subLocality}, '
            '${place.administrativeArea}, ${place.country}');
            
        // Better formatting for Malaysian addresses
        if (place.country == 'Malaysia') {
          if (place.locality?.isNotEmpty == true) {
            return place.locality!;
          } else if (place.subLocality?.isNotEmpty == true) {
            return place.subLocality!;
          } else {
            return '${place.administrativeArea ?? ''}, Malaysia';
          }
        }
        
        // Create a more precise address string
        final List<String> addressParts = [];
        
        if (place.subLocality?.isNotEmpty == true) {
          addressParts.add(place.subLocality!);
        } else if (place.locality?.isNotEmpty == true) {
          addressParts.add(place.locality!);
        }
        
        if (place.administrativeArea?.isNotEmpty == true) {
          addressParts.add(place.administrativeArea!);
        }
        
        if (addressParts.isEmpty) {
          // Fallback to showing the coordinates if we can't get a proper address
          return 'Lat: ${position.latitude.toStringAsFixed(4)}, '
              'Long: ${position.longitude.toStringAsFixed(4)}';
        }
        
        return addressParts.join(', ');
      }
      
      // Fallback to coordinates
      return 'Lat: ${position.latitude.toStringAsFixed(4)}, '
          'Long: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint('Error getting address: $e');
      // Show coordinates if geocoding fails
      return 'Lat: ${position.latitude.toStringAsFixed(4)}, '
          'Long: ${position.longitude.toStringAsFixed(4)}';
    }
  }
}
