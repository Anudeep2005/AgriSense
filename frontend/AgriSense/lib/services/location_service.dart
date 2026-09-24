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

  static LocationData defaultFallback() {
    return LocationData(
      latitude: 16.9891,
      longitude: 81.7839,
      locationName: 'Rajahmundry, AP',
      district: 'East Godavari',
      state: 'Andhra Pradesh',
      country: 'India',
    );
  }
}

class LocationService {
  static Future<LocationData> getLocationData() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services disabled, using default location fallback.');
        return LocationData.defaultFallback();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied, using default location fallback.');
          return LocationData.defaultFallback();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied, using fallback.');
        return LocationData.defaultFallback();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

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
              'Farm Location';
          district = place.subAdministrativeArea ?? place.administrativeArea;
          state = place.administrativeArea;
          country = place.country;
        }
      } catch (geocodingError) {
        locationName = 'Coordinates: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName ?? 'Farm Location',
        district: district,
        state: state,
        country: country,
      );

    } catch (e) {
      print('LocationService fallback triggered: $e');
      return LocationData.defaultFallback();
    }
  }

  static Future<String> getCity() async {
    final locationData = await getLocationData();
    return locationData.locationName ?? 'Rajahmundry, AP';
  }
}