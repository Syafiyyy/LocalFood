import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class RestaurantService {
  final RestaurantRepository _repository = RestaurantRepository();
  final Distance _distance = const Distance();

  // Get all restaurants
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      // Using the existing repository to get restaurant data
      return _repository.getAllRestaurants();
    } catch (e) {
      debugPrint('Error getting restaurants: $e');
      return [];
    }
  }

  // Get restaurants near a specific location
  Future<List<Restaurant>> getNearbyRestaurants(
      {required LatLng userLocation, double maxDistance = 5000}) async {
    try {
      // Get all restaurants from repository
      final restaurants = _repository.getAllRestaurants();

      // Filter by distance and sort
      final nearbyRestaurants = restaurants.where((restaurant) {
        // Calculate distance in meters
        final distanceInMeters =
            _distance.as(LengthUnit.Meter, userLocation, restaurant.location);
        return distanceInMeters <= maxDistance;
      }).toList();

      // Sort by distance
      nearbyRestaurants.sort((a, b) {
        final distanceA =
            _distance.as(LengthUnit.Meter, userLocation, a.location);
        final distanceB =
            _distance.as(LengthUnit.Meter, userLocation, b.location);
        return distanceA.compareTo(distanceB);
      });

      return nearbyRestaurants;
    } catch (e) {
      debugPrint('Error getting nearby restaurants: $e');
      return [];
    }
  }

  // Get featured restaurants (highest rated near user)
  Future<List<Restaurant>> getFeaturedRestaurants(
      {required LatLng userLocation, double maxDistance = 10000}) async {
    try {
      // Get nearby restaurants
      final nearbyRestaurants = await getNearbyRestaurants(
          userLocation: userLocation, maxDistance: maxDistance);

      // Sort by rating (descending)
      nearbyRestaurants.sort((a, b) => b.rating.compareTo(a.rating));

      // Take top 5 or less
      return nearbyRestaurants.take(5).toList();
    } catch (e) {
      debugPrint('Error getting featured restaurants: $e');
      return [];
    }
  }

  // Get restaurants in a specific district or area
  Future<List<Restaurant>> getRestaurantsByArea(String area) async {
    try {
      // Using the existing repository function
      return _repository.getRestaurantsByDistrict(area);
    } catch (e) {
      debugPrint('Error getting restaurants by area: $e');
      return [];
    }
  }

  // Calculate distance between user and restaurant
  String getDistanceString(LatLng userLocation, LatLng restaurantLocation) {
    final distanceInMeters =
        _distance.as(LengthUnit.Meter, userLocation, restaurantLocation);

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  // Get restaurants by search query with location filtering
  Future<List<Restaurant>> searchRestaurants(
      {required String query, String? locationFilter}) async {
    try {
      // Get all restaurants from repository
      final allRestaurants = _repository.getAllRestaurants();

      // Filter by search term
      var filteredRestaurants = allRestaurants.where((restaurant) {
        final nameMatch =
            restaurant.name.toLowerCase().contains(query.toLowerCase());
        final cuisineMatch = restaurant.cuisineTypes.any(
            (cuisine) => cuisine.toLowerCase().contains(query.toLowerCase()));
        final descriptionMatch =
            restaurant.description.toLowerCase().contains(query.toLowerCase());

        return nameMatch || cuisineMatch || descriptionMatch;
      }).toList();

      // Apply location filter if provided
      if (locationFilter != null && locationFilter.isNotEmpty) {
        filteredRestaurants = filteredRestaurants.where((restaurant) {
          return restaurant.address
              .toLowerCase()
              .contains(locationFilter.toLowerCase());
        }).toList();
      }

      return filteredRestaurants;
    } catch (e) {
      debugPrint('Error searching restaurants: $e');
      return [];
    }
  }
}
