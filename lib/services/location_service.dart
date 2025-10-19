
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? district;
  final String? state;
  final String? country;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.district,
    this.state,
    this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'district': district,
      'state': state,
      'country': country,
    };
  }
}

class LocationService {

  static Future<LocationData?> getLocationData() async {
    try {
    
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return null;
      }

     
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      print('GPS Coordinates: ${position.latitude}, ${position.longitude}');

      
      String? locationName;
      String? district;
      String? state;
      String? country;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          
          
          locationName = place.locality ?? 
                        place.subLocality ?? 
                        place.subAdministrativeArea ?? 
                        place.administrativeArea ?? 
                        'Unknown Location';
                        
          district = place.subAdministrativeArea ?? place.administrativeArea;
          state = place.administrativeArea;
          country = place.country;

          print('Location: $locationName, $district, $state, $country');
        }
      } catch (geocodingError) {
        print('Geocoding failed: $geocodingError');
        
        locationName = 'Coordinates: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
        district: district,
        state: state,
        country: country,
      );

    } catch (e) {
      print('LocationService error: $e');
      return null;
    }
  }


  static Future<String?> getCity() async {
    final locationData = await getLocationData();
    return locationData?.locationName;
  }
}