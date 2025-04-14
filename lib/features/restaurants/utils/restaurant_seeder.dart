import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

/// Utility class to seed sample restaurant data in Firestore
class RestaurantSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Reference to the restaurants collection
  CollectionReference get _restaurantsRef => 
      _firestore.collection(FirebaseConstants.restaurantsCollection);
  
  /// Sample Malaysian restaurant data for Kuala Lumpur area
  final List<Map<String, dynamic>> _sampleRestaurants = [
    {
      'id': 'rest-001',
      'name': 'Nasi Kandar Pelita',
      'description': 'Famous for authentic Malaysian Nasi Kandar, offering a variety of curries and side dishes.',
      'rating': 4.5,
      'address': 'Jalan Ampang, Kuala Lumpur',
      'location': {
        'latitude': 3.1577,
        'longitude': 101.7197
      },
      'photos': [
        'assets/images/restaurants/nasi_kandar_pelita.jpg',
      ],
      'cuisineTypes': ['Malaysian', 'Indian', 'Halal'],
      'hours': {
        'monday': '24 hours',
        'tuesday': '24 hours',
        'wednesday': '24 hours',
        'thursday': '24 hours',
        'friday': '24 hours',
        'saturday': '24 hours',
        'sunday': '24 hours'
      },
      'features': ['Dine-in', 'Takeaway', '24 Hours'],
      'priceLevel': 'RM',
      'phoneNumber': '+60321441124'
    },
    {
      'id': 'rest-002',
      'name': 'Jalan Alor Food Street',
      'description': 'Popular food street with numerous hawker stalls offering a wide variety of local Chinese cuisine.',
      'rating': 4.6,
      'address': 'Jalan Alor, Bukit Bintang, Kuala Lumpur',
      'location': {
        'latitude': 3.1456,
        'longitude': 101.7077
      },
      'photos': [
        'assets/images/restaurants/jalan_alor.jpg',
      ],
      'cuisineTypes': ['Chinese', 'Street Food', 'Seafood'],
      'hours': {
        'monday': '5:00 PM - 1:00 AM',
        'tuesday': '5:00 PM - 1:00 AM',
        'wednesday': '5:00 PM - 1:00 AM',
        'thursday': '5:00 PM - 1:00 AM',
        'friday': '5:00 PM - 3:00 AM',
        'saturday': '5:00 PM - 3:00 AM',
        'sunday': '5:00 PM - 1:00 AM'
      },
      'features': ['Outdoor Seating', 'Street Food', 'Late Night'],
      'priceLevel': 'RM',
      'phoneNumber': null
    },
    {
      'id': 'rest-003',
      'name': 'Restoran Rebung',
      'description': 'Celebrity chef Dato Chef Ismail\'s restaurant offering authentic Malay cuisine and traditional dishes.',
      'rating': 4.3,
      'address': 'Cascade Parking, Jalan Sultan Ismail, Kuala Lumpur',
      'location': {
        'latitude': 3.1531,
        'longitude': 101.7104
      },
      'photos': [
        'assets/images/restaurants/restoran_rebung.jpg',
      ],
      'cuisineTypes': ['Malay', 'Traditional', 'Halal'],
      'hours': {
        'monday': '11:00 AM - 10:00 PM',
        'tuesday': '11:00 AM - 10:00 PM',
        'wednesday': '11:00 AM - 10:00 PM',
        'thursday': '11:00 AM - 10:00 PM',
        'friday': '11:00 AM - 10:00 PM',
        'saturday': '11:00 AM - 10:00 PM',
        'sunday': '11:00 AM - 10:00 PM'
      },
      'features': ['Buffet', 'Traditional Cuisine', 'Family Friendly'],
      'priceLevel': 'RM RM',
      'phoneNumber': '+60321442033'
    },
    {
      'id': 'rest-004',
      'name': 'Lot 10 Hutong',
      'description': 'Food court featuring famous Malaysian Chinese hawker stalls all in one location.',
      'rating': 4.4,
      'address': 'Lot 10 Shopping Centre, Bukit Bintang, Kuala Lumpur',
      'location': {
        'latitude': 3.1468,
        'longitude': 101.7113
      },
      'photos': [
        'assets/images/restaurants/lot10_hutong.jpg',
      ],
      'cuisineTypes': ['Chinese', 'Malaysian', 'Food Court'],
      'hours': {
        'monday': '10:00 AM - 10:00 PM',
        'tuesday': '10:00 AM - 10:00 PM',
        'wednesday': '10:00 AM - 10:00 PM',
        'thursday': '10:00 AM - 10:00 PM',
        'friday': '10:00 AM - 10:00 PM',
        'saturday': '10:00 AM - 10:00 PM',
        'sunday': '10:00 AM - 10:00 PM'
      },
      'features': ['Air Conditioned', 'Food Court', 'Shopping Mall'],
      'priceLevel': 'RM',
      'phoneNumber': '+60321418833'
    },
    {
      'id': 'rest-005',
      'name': 'Old Town White Coffee',
      'description': 'Malaysian chain offering traditional kopitiam experience with white coffee and local dishes.',
      'rating': 4.0,
      'address': 'Various branches around Kuala Lumpur',
      'location': {
        'latitude': 3.1479,
        'longitude': 101.7142
      },
      'photos': [
        'assets/images/restaurants/old_town.jpg',
      ],
      'cuisineTypes': ['Malaysian', 'Cafe', 'Coffee'],
      'hours': {
        'monday': '8:00 AM - 10:00 PM',
        'tuesday': '8:00 AM - 10:00 PM',
        'wednesday': '8:00 AM - 10:00 PM',
        'thursday': '8:00 AM - 10:00 PM',
        'friday': '8:00 AM - 10:00 PM',
        'saturday': '8:00 AM - 10:00 PM',
        'sunday': '8:00 AM - 10:00 PM'
      },
      'features': ['Wifi', 'Coffee', 'Casual Dining'],
      'priceLevel': 'RM',
      'phoneNumber': '+60321425778'
    },
    {
      'id': 'rest-006',
      'name': 'Madam Kwan\'s',
      'description': 'Popular restaurant known for its Malaysian classics like Nasi Lemak and Curry Laksa.',
      'rating': 4.2,
      'address': 'KLCC, Kuala Lumpur',
      'location': {
        'latitude': 3.1588,
        'longitude': 101.7123
      },
      'photos': [
        'assets/images/restaurants/madam_kwans.jpg',
      ],
      'cuisineTypes': ['Malaysian', 'Chinese', 'Nyonya'],
      'hours': {
        'monday': '11:00 AM - 10:00 PM',
        'tuesday': '11:00 AM - 10:00 PM',
        'wednesday': '11:00 AM - 10:00 PM',
        'thursday': '11:00 AM - 10:00 PM',
        'friday': '11:00 AM - 10:00 PM',
        'saturday': '11:00 AM - 10:00 PM',
        'sunday': '11:00 AM - 10:00 PM'
      },
      'features': ['Mall Location', 'Family Dining', 'Tourist Favorite'],
      'priceLevel': 'RM RM',
      'phoneNumber': '+60321635228'
    },
    {
      'id': 'rest-007',
      'name': 'Banana Leaf Curry House',
      'description': 'Authentic South Indian restaurant serving food on banana leaves with various curries and sides.',
      'rating': 4.1,
      'address': 'Bangsar, Kuala Lumpur',
      'location': {
        'latitude': 3.1289,
        'longitude': 101.6767
      },
      'photos': [
        'assets/images/restaurants/banana_leaf.jpg',
      ],
      'cuisineTypes': ['Indian', 'South Indian', 'Vegetarian Friendly'],
      'hours': {
        'monday': '10:00 AM - 10:00 PM',
        'tuesday': '10:00 AM - 10:00 PM',
        'wednesday': '10:00 AM - 10:00 PM',
        'thursday': '10:00 AM - 10:00 PM',
        'friday': '10:00 AM - 10:00 PM',
        'saturday': '10:00 AM - 10:00 PM',
        'sunday': '10:00 AM - 10:00 PM'
      },
      'features': ['Banana Leaf', 'Vegetarian Options', 'Spicy Food'],
      'priceLevel': 'RM',
      'phoneNumber': '+60322822303'
    },
    {
      'id': 'rest-008',
      'name': 'Din Tai Fung',
      'description': 'World-famous Taiwanese restaurant known for its soup dumplings (xiao long bao) and dim sum.',
      'rating': 4.7,
      'address': 'Pavilion Kuala Lumpur',
      'location': {
        'latitude': 3.1490,
        'longitude': 101.7131
      },
      'photos': [
        'assets/images/restaurants/din_tai_fung.jpg',
      ],
      'cuisineTypes': ['Taiwanese', 'Chinese', 'Dumplings'],
      'hours': {
        'monday': '11:00 AM - 10:00 PM',
        'tuesday': '11:00 AM - 10:00 PM',
        'wednesday': '11:00 AM - 10:00 PM',
        'thursday': '11:00 AM - 10:00 PM',
        'friday': '11:00 AM - 10:00 PM',
        'saturday': '11:00 AM - 10:00 PM',
        'sunday': '11:00 AM - 10:00 PM'
      },
      'features': ['Mall Location', 'International Chain', 'Upscale'],
      'priceLevel': 'RM RM',
      'phoneNumber': '+60321488292'
    },
    {
      'id': 'rest-009',
      'name': 'Betel Leaf',
      'description': 'Contemporary restaurant serving authentic Northern and Southern Indian cuisine.',
      'rating': 4.3,
      'address': 'Lebuh Ampang, Kuala Lumpur',
      'location': {
        'latitude': 3.1516,
        'longitude': 101.6958
      },
      'photos': [
        'assets/images/restaurants/betel_leaf.jpg',
      ],
      'cuisineTypes': ['Indian', 'Contemporary', 'Cocktails'],
      'hours': {
        'monday': '12:00 PM - 11:00 PM',
        'tuesday': '12:00 PM - 11:00 PM',
        'wednesday': '12:00 PM - 11:00 PM',
        'thursday': '12:00 PM - 11:00 PM',
        'friday': '12:00 PM - 12:00 AM',
        'saturday': '12:00 PM - 12:00 AM',
        'sunday': '12:00 PM - 11:00 PM'
      },
      'features': ['Bar', 'Dinner', 'Upscale Casual'],
      'priceLevel': 'RM RM',
      'phoneNumber': '+60321810500'
    },
    {
      'id': 'rest-010',
      'name': 'Village Park Restaurant',
      'description': 'Local favorite famous for its nasi lemak with crispy fried chicken.',
      'rating': 4.6,
      'address': 'Damansara Utama, Petaling Jaya',
      'location': {
        'latitude': 3.1336,
        'longitude': 101.6215
      },
      'photos': [
        'assets/images/restaurants/village_park.jpg',
      ],
      'cuisineTypes': ['Malaysian', 'Malay', 'Breakfast'],
      'hours': {
        'monday': '7:30 AM - 7:30 PM',
        'tuesday': '7:30 AM - 7:30 PM',
        'wednesday': '7:30 AM - 7:30 PM',
        'thursday': '7:30 AM - 7:30 PM',
        'friday': '7:30 AM - 7:30 PM',
        'saturday': '7:30 AM - 7:30 PM',
        'sunday': '7:30 AM - 7:30 PM'
      },
      'features': ['Breakfast', 'Local Favorite', 'Nasi Lemak'],
      'priceLevel': 'RM',
      'phoneNumber': '+60377109069'
    }
  ];

  /// Seed the database with sample restaurants
  Future<void> seedRestaurants() async {
    try {
      // Check if restaurants already exist
      final snapshot = await _restaurantsRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Restaurants already exist in the database. Skipping seeding.');
        return;
      }
      
      // Add each sample restaurant to Firestore
      for (final restaurantData in _sampleRestaurants) {
        await _restaurantsRef.doc(restaurantData['id']).set(restaurantData);
        print('Added restaurant: ${restaurantData['name']}');
      }
      
      print('Successfully seeded ${_sampleRestaurants.length} restaurants!');
    } catch (e) {
      print('Error seeding restaurants: $e');
      rethrow;
    }
  }
  
  /// Clear all restaurant data from Firestore
  Future<void> clearRestaurants() async {
    try {
      final snapshot = await _restaurantsRef.get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
        print('Deleted restaurant: ${doc.id}');
      }
      
      print('Successfully cleared all restaurants!');
    } catch (e) {
      print('Error clearing restaurants: $e');
      rethrow;
    }
  }
}
