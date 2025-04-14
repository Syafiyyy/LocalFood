import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';

class RestaurantRepository {
  static final RestaurantRepository _instance =
      RestaurantRepository._internal();

  factory RestaurantRepository() {
    return _instance;
  }

  RestaurantRepository._internal();

  // Get all restaurants
  List<Restaurant> getAllRestaurants() {
    List<Restaurant> allRestaurants = [];
    allRestaurants.addAll(getPetalingJayaRestaurants());
    allRestaurants.addAll(getGombakRestaurants());
    allRestaurants.addAll(getHuluLangatRestaurants());
    allRestaurants.addAll(getKualaLangatRestaurants());
    allRestaurants.addAll(getKualaSelangorRestaurants());
    allRestaurants.addAll(getSabakBernamRestaurants());
    allRestaurants.addAll(getKlangRestaurants());
    allRestaurants.addAll(getSepangRestaurants());
    allRestaurants.addAll(getHuluSelangorRestaurants());
    // Add more district restaurant lists as you create them
    return allRestaurants;
  }

  // Get a restaurant by ID
  Restaurant? getRestaurantById(String id) {
    final allRestaurants = getAllRestaurants();
    try {
      return allRestaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get restaurants by district name
  List<Restaurant> getRestaurantsByDistrict(String districtName) {
    switch (districtName.toLowerCase()) {
      case 'gombak':
        return getGombakRestaurants();
      case 'petaling':
        return getPetalingJayaRestaurants();
      case 'hulu langat':
        return getHuluLangatRestaurants();
      case 'kuala langat':
        return getKualaLangatRestaurants();
      case 'kuala selangor':
        return getKualaSelangorRestaurants();
      case 'sabak bernam':
        return getSabakBernamRestaurants();
      case 'klang':
        return getKlangRestaurants();
      case 'sepang':
        return getSepangRestaurants();
      case 'hulu selangor':
        return getHuluSelangorRestaurants();
      default:
        // If district name doesn't match, try to filter by address
        return getAllRestaurants()
            .where((restaurant) => restaurant.address
                .toLowerCase()
                .contains(districtName.toLowerCase()))
            .toList();
    }
  }

  // Sample restaurant data for Petaling Jaya
  List<Restaurant> getPetalingJayaRestaurants() {
    return [
      Restaurant(
        id: "village-park",
        name: "Village Park Restaurant",
        description:
            "Terkenal dengan nasi lemak dan roti canai. Village Park is one of the most popular Malay restaurants in Petaling Jaya, known for its signature nasi lemak with crispy fried chicken and aromatic sambal.",
        rating: 4.2,
        address:
            "5 Jalan Ss 21/37 Damansara Utama, Petaling Jaya 47400 Malaysia",
        location: LatLng(3.1183289, 101.6210927),
        photos: [
          "assets/images/restaurants/village 1.jpg",
          "assets/images/restaurants/village 2.jpg",
          "assets/images/restaurants/village 3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Halal", "Local"],
        hours: {
          "Monday": "7:00 AM - 7:30 PM",
          "Tuesday": "7:00 AM - 7:30 PM",
          "Wednesday": "7:00 AM - 7:30 PM",
          "Thursday": "7:00 AM - 7:30 PM",
          "Friday": "7:00 AM - 7:30 PM",
          "Saturday": "7:00 AM - 7:30 PM",
          "Sunday": "7:00 AM - 6:00 PM",
        },
        features: [
          "Breakfast",
          "Lunch",
          "Brunch",
          "Table Service",
          "Takeout",
          "Halal"
        ],
        website: "https://example.com/village-park",
        phoneNumber: "+60 3-7710 7860",
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "kafe-bawang-merah",
        name: "Kafé Bawang Merah",
        description:
            "Menawarkan soto ayam dan laksa Johor yang autentik. A comfortable cafe known for its Johor-style laksa and delicious soto ayam dishes, bringing authentic Malaysian flavors to Petaling Jaya.",
        rating: 4.0,
        address: "Jalan SS 15, Subang Jaya, Petaling Jaya 47500 Malaysia",
        location: LatLng(3.0758, 101.5861),
        photos: [
          "assets/images/restaurants/bawang_merah_1.jpg",
          "assets/images/restaurants/bawang_merah_2.jpg",
          "assets/images/restaurants/bawang_merah_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Halal", "Traditional"],
        hours: {
          "Monday": "9:00 AM - 6:00 PM",
          "Tuesday": "9:00 AM - 6:00 PM",
          "Wednesday": "9:00 AM - 6:00 PM",
          "Thursday": "9:00 AM - 6:00 PM",
          "Friday": "9:00 AM - 6:00 PM",
          "Saturday": "9:00 AM - 6:00 PM",
          "Sunday": "Closed",
        },
        features: ["Lunch", "Takeout", "Casual Dining", "Muslim-friendly"],
        website: null,
        phoneNumber: "016-909 9873",
        priceLevel: "\$",
      ),
      Restaurant(
        id: "gold-chili",
        name: "Gold Chili Restaurant",
        description:
            "Terkenal dengan buttermilk chicken yang lazat. Gold Chili is a local favorite serving Chinese-Malaysian cuisine with their signature buttermilk chicken dish and various seafood specialties.",
        rating: 4.1,
        address:
            "Lot 12A Ss 12 Jalan Ss 12/1b Opposite Hotel Grand Dorsett, Subang Jaya 47500 Malaysia",
        location: LatLng(3.04384000, 101.58062000),
        photos: [
          "assets/images/restaurants/gold_chili_1.jpg",
          "assets/images/restaurants/gold_chili_2.jpg",
          "assets/images/restaurants/gold_chili_3.jpg",
        ],
        cuisineTypes: ["Chinese", "Malaysian", "Seafood"],
        hours: {
          "Monday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
          "Tuesday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
          "Wednesday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
          "Thursday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
          "Friday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
          "Saturday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
          "Sunday": "11:30 AM - 3:00 PM, 5:30 PM - 10:00 PM",
        },
        features: ["Lunch", "Dinner", "Table Service", "Takeout"],
        website: null,
        phoneNumber: "+60 3-5621 6100",
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "the-teddy",
        name: "The Teddy Cafe & Restaurant",
        description:
            "Menyajikan menu pelbagai dengan suasana santai. The Teddy offers a diverse menu in a relaxed atmosphere, popular for its creative dishes and cozy ambiance.",
        rating: 4.4,
        address:
            "Zenith Corporate Park, 22G-B, Jalan SS 7/26, Ss 7, 47301 Petaling Jaya, Selangor",
        location: LatLng(3.104205, 101.592140),
        photos: [
          "assets/images/restaurants/teddy_cafe_1.jpg",
          "assets/images/restaurants/teddy_cafe_2.jpg",
          "assets/images/restaurants/teddy_cafe_3.jpg",
        ],
        cuisineTypes: ["Cafe", "Fusion", "Western"],
        hours: {
          "Monday": "Closed",
          "Tuesday": "12:00 PM - 10:00 PM",
          "Wednesday": "12:00 PM - 10:00 PM",
          "Thursday": "12:00 PM - 10:00 PM",
          "Friday": "12:00 PM - 10:00 PM",
          "Saturday": "12:00 PM - 10:00 PM",
          "Sunday": "12:00 PM - 10:00 PM",
        },
        features: ["Lunch", "Dinner", "Cafe", "Cozy Atmosphere"],
        website: null,
        phoneNumber: "016-500 9409",
        priceLevel: "\$\$",
      ),
    ];
  }

  // Sample restaurant data for Gombak
  List<Restaurant> getGombakRestaurants() {
    return [
      Restaurant(
        id: "kari-kepala-ikan",
        name: "Restoran Kari Kepala Ikan SG",
        description:
            "Popular restaurant known for its flavorful fish head curry and authentic Malaysian dishes. A must-visit spot in Gombak for curry lovers.",
        rating: 4.2,
        address: "10-12 Jalan 1/8 Taman Seri Gombak, Batu Caves 68100 Malaysia",
        location: LatLng(3.243399, 101.698259), // Updated to actual coordinates
        photos: [
          "assets/images/restaurants/kepala_ikan_1.jpg",
          "assets/images/restaurants/kepala_ikan_2.jpg",
          "assets/images/restaurants/kepala_ikan_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Seafood", "Indian"],
        hours: {
          "Monday": "11:00 AM - 9:00 PM",
          "Tuesday": "11:00 AM - 9:00 PM",
          "Wednesday": "11:00 AM - 9:00 PM",
          "Thursday": "11:00 AM - 9:00 PM",
          "Friday": "11:00 AM - 9:00 PM",
          "Saturday": "11:00 AM - 9:00 PM",
          "Sunday": "11:00 AM - 9:00 PM",
        },
        features: ["Lunch", "Dinner", "Fish Head Curry", "Takeout", "Halal"],
        website: null,
        phoneNumber: "+60 3-6189 3657",
        priceLevel: "\$\$",
      ),
      // Removed Restoran Dapur Abe since it's actually in Shah Alam, not Gombak
      Restaurant(
        id: "farm-cafe",
        name: "Farm Cafe",
        description:
            "Charming cafe with farm-to-table concept serving fresh, organic dishes in a relaxing garden atmosphere. Perfect for those seeking healthy options.",
        rating: 4.5,
        address:
            "1, Jalan Industri Batu Caves 1/1, Taman Perindustrian, 68100 Batu Caves, Selangor",
        location: LatLng(3.2374, 101.6839),
        photos: [
          "assets/images/restaurants/farm_cafe_1.jpg",
          "assets/images/restaurants/farm_cafe_2.jpg",
          "assets/images/restaurants/farm_cafe_3.jpg",
        ],
        cuisineTypes: ["Cafe", "Organic", "Healthy"],
        hours: {
          "Sunday": "10:00 AM - 11:00 PM",
          "Monday": "10:00 AM - 11:00 PM",
          "Tuesday": "10:00 AM - 11:00 PM",
          "Wednesday": "Closed",
          "Thursday": "10:00 AM - 11:00 PM",
          "Friday": "10:00 AM - 11:00 PM",
          "Saturday": "10:00 AM - 11:00 PM",
        },
        features: [
          "Lunch",
          "Dinner",
          "Organic",
          "Outdoor Seating",
          "Vegetarian Options",
          "Wi-Fi"
        ],
        website: "facebook.com",
        phoneNumber: "012-724 2105",
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "d-pojee-cafe",
        name: "D' POJEE CAFE",
        description:
            "Trendy local cafe offering a mix of Malaysian and Western cuisine in a comfortable setting. Known for great coffee and affordable meals.",
        rating: 4.0,
        address:
            "Lot G-3, No.78, Jalan Prima Sri Gombak, Prima Seri Gombak, 68100 Batu Caves, Selangor",
        location: LatLng(3.236851, 101.700477),
        photos: [
          "assets/images/restaurants/pojee_1.jpg",
          "assets/images/restaurants/pojee_2.jpg",
          "assets/images/restaurants/pojee_3.jpg",
        ],
        cuisineTypes: ["Cafe", "Malaysian", "Western"],
        hours: {
          "Sunday": "12:00 PM - 11:30 PM",
          "Monday": "12:00 PM - 11:30 PM",
          "Tuesday": "12:00 PM - 11:30 PM",
          "Wednesday": "12:00 PM - 11:30 PM",
          "Thursday": "12:00 PM - 11:30 PM",
          "Friday": "12:00 PM - 11:30 PM",
          "Saturday": "12:00 PM - 11:30 PM",
        },
        features: ["Lunch", "Dinner", "Coffee", "Wi-Fi"],
        website: null,
        phoneNumber: "019-328 2160",
        priceLevel: "\$",
      ),
    ];
  }

  // Sample restaurant data for Hulu Langat
  List<Restaurant> getHuluLangatRestaurants() {
    return [
      Restaurant(
        id: "selera-kampung",
        name: "Restoran Selera Kampung",
        description:
            "Highly-rated traditional restaurant serving authentic kampung-style dishes in a casual, friendly environment. Known for its flavorful home-cooked Malaysian cuisine.",
        rating: 4.8,
        address: "139a, Kampung Sungai Serai, 43100 Hulu Langat, Selangor",
        location: LatLng(3.163934, 101.847529),
        photos: [
          "assets/images/restaurants/selera_kampung_1.jpg",
          "assets/images/restaurants/selera_kampung_2.jpg",
          "assets/images/restaurants/selera_kampung_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Traditional", "Kampung"],
        hours: {
          "Monday": "6:30 AM - 4:00 PM",
          "Tuesday": "6:30 AM - 4:00 PM",
          "Wednesday": "6:30 AM - 4:00 PM",
          "Thursday": "6:30 AM - 4:00 PM",
          "Friday": "6:30 AM - 4:00 PM",
          "Saturday": "6:30 AM - 4:00 PM",
          "Sunday": "6:30 AM - 4:00 PM",
        },
        features: [
          "Breakfast",
          "Lunch",
          "Traditional",
          "Family-friendly",
          "Halal"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$",
      ),
      Restaurant(
        id: "kafe-laku",
        name: "Kafe Laku",
        description:
            "Popular evening cafe in Hulu Langat offering a blend of Malaysian and Western dishes in a cozy setting. Perfect spot for dinner and gatherings.",
        rating: 4.8,
        address:
            "206, Jalan Hulu Langat, Batu 12, 1/2, Kampung Dusun Nanding, 43100 Hulu Langat, Selangor",
        location: LatLng(3.163934, 101.847529),
        photos: [
          "assets/images/restaurants/kafe_laku_1.jpg",
          "assets/images/restaurants/kafe_laku_2.jpg",
          "assets/images/restaurants/kafe_laku_3.jpg",
        ],
        cuisineTypes: ["Cafe", "Malaysian", "Fusion"],
        hours: {
          "Monday": "4:00 PM - 11:00 PM",
          "Tuesday": "4:00 PM - 11:00 PM",
          "Wednesday": "4:00 PM - 11:00 PM",
          "Thursday": "4:00 PM - 11:00 PM",
          "Friday": "4:00 PM - 11:00 PM",
          "Saturday": "4:00 PM - 11:00 PM",
          "Sunday": "Closed",
        },
        features: ["Dinner", "Cafe", "Takeout", "Casual Dining"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "terra-pong",
        name: "Restoran Terra Pong Batu 18",
        description:
            "Established restaurant at Batu 18 serving a variety of local dishes and Chinese-Malaysian cuisine. Known for its relaxed atmosphere and generous portions.",
        rating: 4.2,
        address: "Lot 679, Pekan Batu Lapan Belas, 43100 Hulu Langat, Selangor",
        location: LatLng(3.163934, 101.847529),
        photos: [
          "assets/images/restaurants/terra_pong_1.jpg",
          "assets/images/restaurants/terra_pong_2.jpg",
          "assets/images/restaurants/terra_pong_3.jpg",
        ],
        cuisineTypes: ["Chinese", "Malaysian", "Local"],
        hours: {
          "Monday": "12:00 PM - 11:00 PM",
          "Tuesday": "12:00 PM - 11:00 PM",
          "Wednesday": "12:00 PM - 11:00 PM",
          "Thursday": "12:00 PM - 11:00 PM",
          "Friday": "12:00 PM - 11:00 PM",
          "Saturday": "12:00 PM - 11:00 PM",
          "Sunday": "12:00 PM - 11:00 PM",
        },
        features: ["Lunch", "Dinner", "Group-friendly", "Family-style"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "daging-salai-house",
        name: "Daging Salai House Hulu Langat",
        description:
            "Specialty restaurant focused on traditional smoked meat dishes. A unique culinary experience featuring authentic Malaysian smoked meat recipes.",
        rating: 4.1,
        address: "Kampung Dusun Nanding, 43100 Hulu Langat, Selangor",
        location: LatLng(3.163934, 101.847529),
        photos: [
          "assets/images/restaurants/daging_salai_1.jpg",
          "assets/images/restaurants/daging_salai_2.jpg",
          "assets/images/restaurants/daging_salai_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Smoked Meat", "Traditional"],
        hours: {
          "Sunday": "9:00 AM - 5:00 PM",
          "Monday": "9:00 AM - 5:00 PM",
          "Tuesday": "10:00 AM - 5:00 PM",
          "Wednesday": "9:00 AM - 5:00 PM",
          "Thursday": "9:00 AM - 5:00 PM",
          "Friday": "9:00 AM - 5:00 PM",
          "Saturday": "10:00 AM - 5:00 PM",
        },
        features: ["Lunch", "Specialty Meat", "Takeout", "Traditional"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
    ];
  }

  // Sample restaurant data for Kuala Langat
  List<Restaurant> getKualaLangatRestaurants() {
    return [
      Restaurant(
        id: "pak-fong",
        name: "Pak Fong Restaurant",
        description:
            "Popular local Chinese restaurant located in Bandar Rimbayu offering traditional and fusion Chinese cuisine. Known for its fresh ingredients and welcoming atmosphere.",
        rating: 4.3,
        address:
            "Blossom Square, 19-G, 3, Jalan Flora 1, Bandar Rimbayu, 42500 Telok Panglima Garang, Selangor",
        location: LatLng(
            2.936623, 101.503462), // Approximate coordinates for Bandar Rimbayu
        photos: [
          "assets/images/restaurants/pak_fong_1.jpg",
          "assets/images/restaurants/pak_fong_2.jpg",
          "assets/images/restaurants/pak_fong_3.jpg",
        ],
        cuisineTypes: ["Chinese", "Malaysian-Chinese", "Seafood"],
        hours: {
          "Monday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
          "Tuesday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
          "Wednesday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
          "Thursday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
          "Friday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
          "Saturday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
          "Sunday": "8:30 AM - 2:30 PM, 5:00 PM - 9:30 PM",
        },
        features: ["Lunch", "Dinner", "Family-friendly", "Takeout"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "nasi-kukus-cik-ros",
        name: "Nasi Kukus Cik Ros",
        description:
            "Popular local restaurant specializing in steamed rice served with a variety of traditional Malay dishes and side options. Known for its affordable and flavorful meals.",
        rating: 4.3,
        address: "Kanchong Darat, 42700 Banting, Selangor",
        location: LatLng(
            2.823989, 101.539689), // Approximate coordinates for Kanchong Darat
        photos: [
          "assets/images/restaurants/nasi_kukus_1.jpg",
          "assets/images/restaurants/nasi_kukus_2.jpg",
          "assets/images/restaurants/nasi_kukus_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Malay", "Local"],
        hours: {
          "Monday": "10:00 AM - 10:00 PM",
          "Tuesday": "10:00 AM - 10:00 PM",
          "Wednesday": "10:00 AM - 10:00 PM",
          "Thursday": "10:00 AM - 10:00 PM",
          "Friday": "10:00 AM - 10:00 PM",
          "Saturday": "10:00 AM - 10:00 PM",
          "Sunday": "10:00 AM - 10:00 PM",
        },
        features: [
          "Lunch",
          "Dinner",
          "Takeaway",
          "Dine-in",
          "Halal",
          "Local Favorite"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$",
      ),
      Restaurant(
        id: "i-suka-restaurant",
        name: "I Suka Restaurant Sdn. Bhd.",
        description:
            "Malaysian restaurant within Daifuku Japanese Restaurant Pulau Carey complex, offering a diverse menu of local favorites in a casual setting.",
        rating: 4.2,
        address:
            "319, Batu 11/2, Jalan Bandar Lama Telok Panglima Garang, 42500 Kuala Langat, Selangor",
        location: LatLng(2.993845,
            101.481941), // Approximate coordinates for Telok Panglima Garang
        photos: [
          "assets/images/restaurants/suka_1.jpg",
          "assets/images/restaurants/suka_2.jpg",
          "assets/images/restaurants/suka_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Asian", "Local"],
        hours: {
          "Monday": "11:00 AM - 11:00 PM",
          "Tuesday": "11:00 AM - 11:00 PM",
          "Wednesday": "11:00 AM - 11:00 PM",
          "Thursday": "11:00 AM - 11:00 PM",
          "Friday": "11:00 AM - 11:00 PM",
          "Saturday": "11:00 AM - 11:00 PM",
          "Sunday": "11:00 AM - 11:00 PM",
        },
        features: ["Lunch", "Dinner", "Takeaway", "Dine-in", "Casual Dining"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
    ];
  }

  // Sample restaurant data for Sabak Bernam
  List<Restaurant> getSabakBernamRestaurants() {
    return [
      Restaurant(
        id: "nasi-lemak-batu-40",
        name: "Nasi Lemak Batu 40, Sabak Bernam",
        description:
            "Local favorite serving authentic Malaysian nasi lemak in Sabak Bernam. Known for its flavorful dishes and outdoor seating area.",
        rating: 4.5,
        address:
            "E43, JALAN HAJI MUHAMMAD BATU 40, Kampung Batu Empat Puloh, 45200 Sabak, Selangor",
        location: LatLng(
            3.763607, 100.985832), // Approximate coordinates for Sabak Bernam
        photos: [
          "assets/images/restaurants/lemak_bernam_1.jpg",
          "assets/images/restaurants/lemak_bernam_2.jpg",
          "assets/images/restaurants/lemak_bernam_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Nasi Lemak", "Local"],
        hours: {
          "Monday": "7:00 AM - 6:00 PM",
          "Tuesday": "7:00 AM - 6:00 PM",
          "Wednesday": "7:00 AM - 6:00 PM",
          "Thursday": "7:00 AM - 6:00 PM",
          "Friday": "7:00 AM - 6:00 PM",
          "Saturday": "7:00 AM - 6:00 PM",
          "Sunday": "7:00 AM - 6:00 PM",
        },
        features: ["Breakfast", "Lunch", "Outdoor Seating", "Takeout"],
        website: null,
        phoneNumber: "010-767 2826",
        priceLevel: "\$",
      ),
      Restaurant(
        id: "nawavi-seafood",
        name: "Restoran Nawavi Seafood",
        description:
            "Popular seafood restaurant in Pekan Sabak Bernam offering fresh seafood dishes with local flavors. A must-visit for seafood lovers in the area.",
        rating: 4.3,
        address: "B53, Pekan Sabak Bernam, 45200 Sabak, Selangor",
        location: LatLng(3.769843,
            100.984804), // Approximate coordinates for Pekan Sabak Bernam
        photos: [
          "assets/images/restaurants/nawavi_1.jpg",
          "assets/images/restaurants/nawavi_2.jpg",
          "assets/images/restaurants/nawavi_3.jpg",
        ],
        cuisineTypes: ["Seafood", "Malaysian", "Chinese"],
        hours: {
          "Monday": "11:00 AM - 8:00 PM",
          "Tuesday": "11:00 AM - 8:00 PM",
          "Wednesday": "11:00 AM - 8:00 PM",
          "Thursday": "11:30 AM - 8:00 PM",
          "Friday": "11:30 AM - 8:00 PM",
          "Saturday": "11:00 AM - 8:00 PM",
          "Sunday": "11:30 AM - 8:00 PM",
        },
        features: ["Lunch", "Dinner", "Seafood", "Family-friendly"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
    ];
  }

  // Sample restaurant data for Kuala Selangor
  List<Restaurant> getKualaSelangorRestaurants() {
    return [
      Restaurant(
        id: "mustawa-family-cafe",
        name: "Mustawa Family Cafe",
        description:
            "Popular family-friendly cafe in Peninsula Park offering a variety of Malaysian and Western dishes in a welcoming environment. Known for its comfortable atmosphere and consistent service.",
        rating: 4.3,
        address:
            "46, Jln Peninsular Utama 1, Peninsula Park, 45000 Kuala Selangor, Selangor",
        location: LatLng(3.349503,
            101.255237), // Approximate coordinates for Peninsula Park, Kuala Selangor
        photos: [
          "assets/images/restaurants/mustawa_1.png",
          "assets/images/restaurants/mustawa_2.png",
          "assets/images/restaurants/mustawa_3.png",
        ],
        cuisineTypes: ["Malaysian", "Western", "Cafe"],
        hours: {
          "Monday": "9:00 AM - 11:00 PM",
          "Tuesday": "9:00 AM - 11:00 PM",
          "Wednesday": "9:00 AM - 11:00 PM",
          "Thursday": "9:00 AM - 11:00 PM",
          "Friday": "9:00 AM - 11:00 PM",
          "Saturday": "9:00 AM - 11:00 PM",
          "Sunday": "9:00 AM - 11:00 PM",
        },
        features: [
          "Breakfast",
          "Lunch",
          "Dinner",
          "Takeaway",
          "Dine-in",
          "No-contact delivery",
          "Family-friendly"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
    ];
  }

  // Sample restaurant data for Klang
  List<Restaurant> getKlangRestaurants() {
    return [
      Restaurant(
        id: "gourmet-corner",
        name: "Gourmet Corner Western Food",
        description:
            "Popular Western food restaurant in Klang offering a variety of delicious dishes including steaks, pasta, and burgers at affordable prices.",
        rating: 4.1,
        address:
            "16 & 18 (Ground Floor Jalan Tiara 2D/KU1, Pusat Perniagaan BBK, 41150 Klang, Selangor",
        location:
            LatLng(3.063650, 101.467624), // Approximate coordinates for Klang
        photos: [
          "assets/images/restaurants/gourmet_1.jpg",
          "assets/images/restaurants/gourmet_2.jpg",
          "assets/images/restaurants/gourmet_3.jpg",
        ],
        cuisineTypes: ["Western", "Steaks", "Pasta"],
        hours: {
          "Monday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
          "Tuesday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
          "Wednesday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
          "Thursday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
          "Friday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
          "Saturday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
          "Sunday": "11:00 AM - 3:00 PM, 5:00 PM - 11:30 PM",
        },
        features: ["Lunch", "Dinner", "Western Cuisine", "Family-friendly"],
        website: null,
        phoneNumber: "017-207 1518",
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "bayleaf-kitchen",
        name: "Bayleaf Kitchen Restaurant - Klang",
        description:
            "Authentic Indian restaurant serving a diverse menu of traditional Indian dishes with vegetarian and vegan options in a contemporary setting.",
        rating: 4.2,
        address:
            "8&10 Lorong Tingkat, Off. Jalan Istana, 41000 Klang, Selangor",
        location:
            LatLng(3.040498, 101.448122), // Approximate coordinates for Klang
        photos: [
          "assets/images/restaurants/bayleaf_1.jpg",
          "assets/images/restaurants/bayleaf_2.jpg",
          "assets/images/restaurants/bayleaf_3.jpg",
        ],
        cuisineTypes: ["Indian", "Vegetarian", "Vegan"],
        hours: {
          "Monday": "Closed",
          "Tuesday": "8:00 AM - 10:00 PM",
          "Wednesday": "8:00 AM - 10:00 PM",
          "Thursday": "8:00 AM - 10:00 PM",
          "Friday": "8:00 AM - 10:00 PM",
          "Saturday": "8:00 AM - 10:00 PM",
          "Sunday": "8:00 AM - 10:00 PM",
        },
        features: [
          "Breakfast",
          "Lunch",
          "Dinner",
          "Vegan Options",
          "Indian Cuisine"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "warung-wak",
        name: "WARUNG WAK WESTERN FOOD",
        description:
            "Highly-rated Western food stall offering delicious and affordable Western dishes with a local twist. Known for excellent value and taste.",
        rating: 4.9,
        address: "Jalan Sungai Udang, Taman Aneka Baru, 41250 Klang, Selangor",
        location:
            LatLng(3.042566, 101.426124), // Approximate coordinates for Klang
        photos: [
          "assets/images/restaurants/wak_1.jpeg",
          "assets/images/restaurants/wak_2.jpg",
          "assets/images/restaurants/wak_3.jpg",
        ],
        cuisineTypes: ["Western", "Malaysian", "Fusion"],
        hours: {
          "Monday": "5:30 PM - 10:30 PM",
          "Tuesday": "5:30 PM - 10:30 PM",
          "Wednesday": "5:30 PM - 10:30 PM",
          "Thursday": "5:30 PM - 10:30 PM",
          "Friday": "5:30 PM - 10:30 PM",
          "Saturday": "5:30 PM - 10:30 PM",
          "Sunday": "Closed",
        },
        features: [
          "Dinner",
          "Outdoor Seating",
          "Western Cuisine",
          "Affordable"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$",
      ),
      Restaurant(
        id: "haji-abu",
        name: "Haji Abu's Food Court and Car Wash",
        description:
            "Unique dining experience combining a food court with car wash services. Offers a variety of local dishes with outdoor seating and live music.",
        rating: 3.8,
        address: "43, Jalan Kota Raja, Kawasan 1, 41000 Klang, Selangor",
        location:
            LatLng(3.033236, 101.452630), // Approximate coordinates for Klang
        photos: [
          "assets/images/restaurants/abu_1.jpg",
          "assets/images/restaurants/abu_2.jpg",
          "assets/images/restaurants/abu_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Mixed", "Local"],
        hours: {
          "Monday": "4:00 PM - 12:00 AM",
          "Tuesday": "4:00 PM - 12:00 AM",
          "Wednesday": "Closed",
          "Thursday": "4:00 PM - 12:00 AM",
          "Friday": "4:00 PM - 12:00 AM",
          "Saturday": "4:00 PM - 12:00 AM",
          "Sunday": "4:00 PM - 12:00 AM",
        },
        features: [
          "Dinner",
          "Outdoor Seating",
          "Live Music",
          "Kids Menu",
          "Car Wash"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
    ];
  }

  // Sample restaurant data for Sepang
  List<Restaurant> getSepangRestaurants() {
    return [
      Restaurant(
        id: "farich-food-house",
        name: "Farich Food House",
        description:
            "Popular restaurant in Kota Warisan serving a variety of local and international dishes with a comfortable dining atmosphere. Known for generous portions and consistent quality.",
        rating: 4.0,
        address:
            "68, Jalan Warisan Megah 1/4, Kota Warisan, 43900 Sepang, Selangor",
        location: LatLng(
            2.827743, 101.704795), // Approximate coordinates for Kota Warisan
        photos: [
          "assets/images/restaurants/farich_1.jpg",
          "assets/images/restaurants/farich_2.jpg",
          "assets/images/restaurants/farich_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Asian", "International"],
        hours: {
          "Monday": "12:00 PM - 12:00 AM",
          "Tuesday": "12:00 PM - 12:00 AM",
          "Wednesday": "12:00 PM - 12:00 AM",
          "Thursday": "12:00 PM - 12:00 AM",
          "Friday": "12:00 PM - 12:00 AM",
          "Saturday": "12:00 PM - 12:00 AM",
          "Sunday": "12:00 PM - 12:00 AM",
        },
        features: ["Lunch", "Dinner", "Takeaway", "Halal"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "salam-noodles",
        name: "Salam Noodles",
        description:
            "Casual noodle restaurant offering an array of delicious noodle dishes from various Asian cuisines. Popular for quick meals and takeaway options.",
        rating: 4.0,
        address: "Kota Warisan, 43900 Sepang, Selangor",
        location: LatLng(
            2.822690, 101.700127), // Approximate coordinates for Kota Warisan
        photos: [
          "assets/images/restaurants/salam_noodles_1.jpg",
          "assets/images/restaurants/salam_noodles_2.jpg",
          "assets/images/restaurants/salam_noodles_3.jpg",
        ],
        cuisineTypes: ["Noodles", "Asian", "Malaysian"],
        hours: {
          "Monday": "11:00 AM - 11:00 PM",
          "Tuesday": "11:00 AM - 11:00 PM",
          "Wednesday": "11:30 AM - 11:00 PM",
          "Thursday": "11:30 AM - 11:00 PM",
          "Friday": "11:30 AM - 11:00 PM",
          "Saturday": "11:30 AM - 11:00 PM",
          "Sunday": "11:30 AM - 11:00 PM",
        },
        features: ["Lunch", "Dinner", "Takeaway", "Asian Cuisine"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$",
      ),
      Restaurant(
        id: "darsa-kota-warisan",
        name: "Restoran DarSA Kota Warisan",
        description:
            "Modern restaurant offering dine-in, takeaway, and delivery services with a varied menu of Malaysian favorites. Known for its convenient location and consistent quality.",
        rating: 4.1,
        address:
            "1G, ARENA WARISAN PUTERI, Kota Warisan, 43900 Sepang, Selangor",
        location: LatLng(2.815369,
            101.696510), // Approximate coordinates for Arena Warisan Puteri
        photos: [
          "assets/images/restaurants/darsa_2.jpg",
          "assets/images/restaurants/darsa_1.jpg",
          "assets/images/restaurants/darsa_3.jpg",
        ],
        cuisineTypes: ["Malaysian", "Asian", "International"],
        hours: {
          "Monday": "11:00 AM - 10:00 PM",
          "Tuesday": "11:00 AM - 10:00 PM",
          "Wednesday": "11:00 AM - 10:00 PM",
          "Thursday": "11:00 AM - 10:00 PM",
          "Friday": "11:00 AM - 12:30 PM, 2:30 PM - 10:00 PM",
          "Saturday": "11:00 AM - 10:00 PM",
          "Sunday": "11:00 AM - 10:00 PM",
        },
        features: ["Lunch", "Dinner", "Dine-in", "Takeaway", "Delivery"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "utan-cafe",
        name: "Utan Cafe",
        description:
            "Relaxed cafe in Bandar Baru Salak Tinggi offering a variety of beverages and light meals in a cozy setting. Popular with locals for casual hangouts.",
        rating: 3.9,
        address: "Bandar Baru Salak Tinggi, 43900 Sepang, Selangor",
        location: LatLng(2.820213,
            101.724440), // Approximate coordinates for Bandar Baru Salak Tinggi
        photos: [
          "assets/images/restaurants/utan_1.jpg",
          "assets/images/restaurants/utan_2.jpg",
          "assets/images/restaurants/utan_3.jpg",
        ],
        cuisineTypes: ["Cafe", "Malaysian", "Western"],
        hours: {
          "Monday": "Closed",
          "Tuesday": "11:00 AM - 11:00 PM",
          "Wednesday": "11:00 AM - 11:00 PM",
          "Thursday": "11:00 AM - 11:00 PM",
          "Friday": "11:00 AM - 11:00 PM",
          "Saturday": "11:00 AM - 11:00 PM",
          "Sunday": "11:00 AM - 11:00 PM",
        },
        features: ["Cafe", "Coffee", "Snacks", "Relaxed Atmosphere"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$",
      ),
    ];
  }

  // Sample restaurant data for Hulu Selangor
  List<Restaurant> getHuluSelangorRestaurants() {
    return [
      Restaurant(
        id: "azzuhdi-nasi-arab",
        name: "Restoran Az-Zuhdi | Nasi Arab Al-Yemeni",
        description:
            "Authentic Yemeni and Arab cuisine restaurant specializing in traditional rice dishes, grilled meats, and Middle Eastern flavors. Known for its authentic recipes and warm atmosphere.",
        rating: 4.3,
        address:
            "5,Jln Bunga Kertas 1B/2, Bukit Sentosa, 48300 Rawang, Selangor",
        location: LatLng(3.399554,
            101.557529), // Approximate coordinates for Bukit Sentosa, Rawang
        photos: [
          "assets/images/restaurants/zuhdi_1.jpg",
          "assets/images/restaurants/zuhdi_2.jpg",
          "assets/images/restaurants/zuhdi_3.jpg",
        ],
        cuisineTypes: ["Arab", "Yemeni", "Middle Eastern"],
        hours: {
          "Monday": "11:00 AM - 10:00 PM",
          "Tuesday": "11:00 AM - 10:00 PM",
          "Wednesday": "11:00 AM - 10:00 PM",
          "Thursday": "11:00 AM - 10:00 PM",
          "Friday": "11:00 AM - 12:30 PM, 2:30 PM - 10:00 PM",
          "Saturday": "11:00 AM - 10:00 PM",
          "Sunday": "11:00 AM - 10:00 PM",
        },
        features: [
          "Lunch",
          "Dinner",
          "Halal",
          "Middle Eastern Cuisine",
          "Authentic"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "mani-thai-cuisine",
        name: "Ma-ni Thai Cuisine",
        description:
            "Authentic Thai restaurant in Hulu Bernam offering traditional Thai flavors and dishes. Known for its authentic recipes and welcoming atmosphere.",
        rating: 4.4,
        address:
            "No. 26, Bt 3/4 Jalan Changkat Asa, Hulu Bernam, 35900 Selangor",
        location: LatLng(
            3.692524, 101.520079), // Approximate coordinates for Hulu Bernam
        photos: [
          "assets/images/restaurants/thai_1.jpg",
          "assets/images/restaurants/thai_2.jpg",
          "assets/images/restaurants/thai_3.jpg",
        ],
        cuisineTypes: ["Thai", "Asian", "Seafood"],
        hours: {
          "Monday": "Closed",
          "Tuesday": "Closed",
          "Wednesday": "Closed",
          "Thursday": "Closed",
          "Friday": "6:00 PM - 10:00 PM",
          "Saturday": "12:00 PM - 3:00 PM, 6:00 PM - 9:00 PM",
          "Sunday": "12:00 PM - 3:00 PM, 6:00 PM - 9:00 PM",
        },
        features: [
          "Dinner",
          "Weekend Lunch",
          "Authentic Thai",
          "Family-friendly"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "bamboo-briyani",
        name: "Bamboo Briyani",
        description:
            "Specialty restaurant known for its unique and flavorful biryani served in bamboo. A unique culinary experience featuring authentic Indian-Malaysian fusion dishes.",
        rating: 4.5,
        address:
            "1, Jalan Kelah 1, taman sri kelah, 44300 Batang Kali, Selangor",
        location: LatLng(
            3.449520, 101.664990), // Approximate coordinates for Batang Kali
        photos: [
          "assets/images/restaurants/bamboo_1.jpg",
          "assets/images/restaurants/bamboo_2.jpg",
          "assets/images/restaurants/bamboo_3.jpg",
        ],
        cuisineTypes: ["Indian", "Briyani", "Malaysian-Indian"],
        hours: {
          "Monday": "11:00 AM - 10:00 PM",
          "Tuesday": "10:00 AM - 10:00 PM",
          "Wednesday": "10:00 AM - 10:00 PM",
          "Thursday": "10:00 AM - 10:00 PM",
          "Friday": "10:00 AM - 10:00 PM",
          "Saturday": "10:00 AM - 10:00 PM",
          "Sunday": "10:00 AM - 10:00 PM",
        },
        features: [
          "Lunch",
          "Dinner",
          "Unique Dining",
          "Halal",
          "Specialty Rice"
        ],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
      Restaurant(
        id: "sakura-cabin",
        name: "Sakura Cabin Restoran",
        description:
            "Charming restaurant offering a unique dining experience in a cabin-style setting. Popular evening spot in Hulu Selangor for gatherings and dinner.",
        rating: 4.4,
        address: "Kampung Batu Tiga Puluh, 48200 Batang Kali, Selangor",
        location: LatLng(
            3.458702, 101.656053), // Approximate coordinates for Batang Kali
        photos: [
          "assets/images/restaurants/sakura_1.jpg",
          "assets/images/restaurants/sakura_2.jpg",
          "assets/images/restaurants/sakura_3.jpg",
        ],
        cuisineTypes: ["Japanese Fusion", "Asian", "Malaysian"],
        hours: {
          "Monday": "3:00 PM - 12:00 AM",
          "Tuesday": "3:00 PM - 12:00 AM",
          "Wednesday": "3:00 PM - 12:00 AM",
          "Thursday": "3:00 PM - 12:00 AM",
          "Friday": "3:00 PM - 12:00 AM",
          "Saturday": "3:00 PM - 12:00 AM",
          "Sunday": "3:00 PM - 12:00 AM",
        },
        features: ["Dinner", "Late Night", "Unique Ambiance", "Group-friendly"],
        website: null,
        phoneNumber: null,
        priceLevel: "\$\$",
      ),
    ];
  }
}
