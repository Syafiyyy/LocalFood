import 'package:latlong2/latlong.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final double rating;
  final String address;
  final LatLng location;
  final List<String> photos;
  final List<String> cuisineTypes;
  final Map<String, dynamic> hours;
  final List<String> features;
  final String? website;
  final String? phoneNumber;
  final String? priceLevel;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.address,
    required this.location,
    required this.photos,
    required this.cuisineTypes,
    required this.hours,
    required this.features,
    this.website,
    this.phoneNumber,
    this.priceLevel,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rating: json['rating'],
      address: json['address'],
      location: LatLng(json['location']['latitude'], json['location']['longitude']),
      photos: List<String>.from(json['photos']),
      cuisineTypes: List<String>.from(json['cuisineTypes']),
      hours: json['hours'],
      features: List<String>.from(json['features']),
      website: json['website'],
      phoneNumber: json['phoneNumber'],
      priceLevel: json['priceLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rating': rating,
      'address': address,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'photos': photos,
      'cuisineTypes': cuisineTypes,
      'hours': hours,
      'features': features,
      'website': website,
      'phoneNumber': phoneNumber,
      'priceLevel': priceLevel,
    };
  }
}
