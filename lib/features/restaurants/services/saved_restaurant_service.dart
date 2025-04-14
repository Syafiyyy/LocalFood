import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurant.dart';
import '../../../core/constants/app_constants.dart';

class SavedRestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is logged in
  User? get currentUser => _auth.currentUser;

  // Get reference to user's saved restaurants collection
  CollectionReference get _savedRestaurantsRef {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(currentUser!.uid)
        .collection('savedRestaurants');
  }

  // Save a restaurant
  Future<void> saveRestaurant(Restaurant restaurant) async {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await _savedRestaurantsRef.doc(restaurant.id).set({
      'restaurantId': restaurant.id,
      'name': restaurant.name,
      'address': restaurant.address,
      'latitude': restaurant.location.latitude,
      'longitude': restaurant.location.longitude,
      'rating': restaurant.rating,
      'savedAt': FieldValue.serverTimestamp(),
      // Store thumbnail photo URL if available
      'thumbnailPhoto': restaurant.photos.isNotEmpty ? restaurant.photos[0] : null,
    });
  }

  // Remove a saved restaurant
  Future<void> removeRestaurant(String restaurantId) async {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await _savedRestaurantsRef.doc(restaurantId).delete();
  }

  // Check if a restaurant is saved
  Future<bool> isRestaurantSaved(String restaurantId) async {
    if (currentUser == null) {
      return false;
    }

    final docSnapshot = await _savedRestaurantsRef.doc(restaurantId).get();
    return docSnapshot.exists;
  }

  // Get all saved restaurants
  Future<List<Map<String, dynamic>>> getSavedRestaurants() async {
    if (currentUser == null) {
      return [];
    }

    final querySnapshot = await _savedRestaurantsRef
        .orderBy('savedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
