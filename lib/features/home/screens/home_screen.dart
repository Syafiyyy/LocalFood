import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:group_project/core/theme/app_theme.dart';
import 'package:group_project/core/constants/app_constants.dart';
import 'package:group_project/core/widgets/gradient_title.dart';
import 'package:group_project/core/services/location_service.dart';
import 'package:group_project/core/utils/distance_utils.dart';
import 'package:group_project/features/auth/providers/auth_provider.dart';
import 'package:group_project/features/profile/screens/profile_screen.dart';
import 'package:group_project/features/districts/screens/district_detail_screen.dart';
import 'package:group_project/features/restaurants/screens/saved_restaurants_screen.dart';
import 'package:group_project/features/restaurants/screens/restaurant_detail_screen.dart';
import 'package:group_project/features/restaurants/services/restaurant_service.dart';
import 'package:group_project/features/restaurants/models/restaurant.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pages for the bottom navigation
    final List<Widget> _pages = [
      const _HomeContent(),
      const SavedRestaurantsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Allow content to flow underneath the bottom nav bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: GradientTitle(
          text: _selectedIndex == 0
              ? AppConstants.appName
              : _selectedIndex == 1
                  ? 'Saved Places'
                  : 'Profile',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed, // Needed for 4+ items
            onTap: (index) {
              setState(() {
                _selectedIndex = index;

                // Restart animations when tab changes
                _animationController.reset();
                _animationController.forward();
              });
            },
            elevation: 8,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_outlined, 0),
                activeIcon: _buildActiveNavIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.bookmark_border_outlined, 1),
                activeIcon: _buildActiveNavIcon(Icons.bookmark, 1),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_outline, 2),
                activeIcon: _buildActiveNavIcon(Icons.person, 2),
                label: 'Profile',
              ),
            ],
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textColorSecondary,
            showUnselectedLabels: true,
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Icon(icon),
    );
  }

  Widget _buildActiveNavIcon(IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
    );
  }
}

/// Home tab content
class _HomeContent extends StatefulWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with WidgetsBindingObserver {
  String _currentAddress = 'Finding location...';
  IconData _locationIcon = Icons.location_searching;
  bool _isLocationLoading = true;
  LatLng? _userLocation;

  // Restaurant data
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _nearbyRestaurants = [];
  List<Restaurant> _featuredRestaurants = [];
  bool _isLoadingRestaurants = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation().then((_) {
      if (_userLocation != null) {
        _loadNearbyRestaurants();
        _loadFeaturedRestaurants();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getCurrentLocation().then((_) {
        if (_userLocation != null) {
          _loadNearbyRestaurants();
          _loadFeaturedRestaurants();
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationIcon = Icons.location_searching;
    });

    try {
      final position = await LocationService.getCurrentPosition();

      if (position != null) {
        _userLocation = LatLng(position.latitude, position.longitude);

        setState(() {
          _locationIcon = Icons.location_on;
        });

        try {
          final address = await LocationService.getAddressFromLatLng(position);
          setState(() {
            _currentAddress = address;
            _isLocationLoading = false;
          });

          // Now that we have location, load the restaurants
          _loadNearbyRestaurants();
          _loadFeaturedRestaurants();
        } catch (e) {
          setState(() {
            _currentAddress = 'Address not available';
            _isLocationLoading = false;
          });
          // Use default location for Kuala Lumpur if we can't get address
          _useDefaultLocation();
        }
      } else {
        setState(() {
          _currentAddress = 'Location access needed';
          _locationIcon = Icons.location_off;
          _isLocationLoading = false;
        });
        // Use default location if we can't get the user's location
        _useDefaultLocation();
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Error getting location';
        _locationIcon = Icons.location_off;
        _isLocationLoading = false;
      });
      // Use default location if there's an error
      _useDefaultLocation();
    }
  }

  // Use a default location (central KL) if we can't get the user's location
  void _useDefaultLocation() {
    // Default to central KL location
    _userLocation = LatLng(3.1390, 101.6869);
    _loadNearbyRestaurants();
    _loadFeaturedRestaurants();
  }

  Future<void> _loadNearbyRestaurants() async {
    if (_userLocation == null) return;

    setState(() {
      _isLoadingRestaurants = true;
    });

    try {
      final restaurants = await _restaurantService.getNearbyRestaurants(
        userLocation: _userLocation!,
        maxDistance:
            15000, // Increased to 15km to ensure some restaurants are found
      );

      setState(() {
        _nearbyRestaurants = restaurants;
        _isLoadingRestaurants = false;
      });

      print('Loaded ${restaurants.length} nearby restaurants');
      // If we still don't have restaurants, try loading all restaurants
      if (restaurants.isEmpty) {
        final allRestaurants = await _restaurantService.getAllRestaurants();
        setState(() {
          // Just show the first 5 restaurants if no nearby restaurants found
          _nearbyRestaurants = allRestaurants.take(5).toList();
        });
        print(
            'Fallback: Loaded ${_nearbyRestaurants.length} restaurants from all restaurants');
      }
    } catch (e) {
      print('Error loading nearby restaurants: $e');
      setState(() {
        _isLoadingRestaurants = false;
      });
    }
  }

  Future<void> _loadFeaturedRestaurants() async {
    if (_userLocation == null) return;

    try {
      final restaurants = await _restaurantService.getFeaturedRestaurants(
        userLocation: _userLocation!,
        maxDistance:
            20000, // Increased to 20km to ensure some restaurants are found
      );

      setState(() {
        _featuredRestaurants = restaurants;
      });

      print('Loaded ${restaurants.length} featured restaurants');
      // If we still don't have featured restaurants, get the highest rated ones
      if (restaurants.isEmpty) {
        final allRestaurants = await _restaurantService.getAllRestaurants();
        // Sort by rating
        allRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
        setState(() {
          _featuredRestaurants = allRestaurants.take(5).toList();
        });
        print(
            'Fallback: Loaded ${_featuredRestaurants.length} restaurants from highest rated');
      }
    } catch (e) {
      print('Error loading featured restaurants: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0,
          80.0), // Added extra bottom padding for navigation bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withRed(220),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                        ),
                        Text(
                          '${user?.name ?? 'Food Lover'}!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Location container replaces search
                GestureDetector(
                  onTap: _getCurrentLocation, // Refresh location when tapped
                  child: _buildLocationContainer(
                    context,
                    _currentAddress,
                    _isLocationLoading
                        ? Icons.location_searching
                        : _locationIcon,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Explore Selangor Districts
          SectionTitle(
            title: 'Explore Selangor Districts',
            viewAll: () {
              // TODO: Navigate to all districts
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 9,
              itemBuilder: (context, index) {
                final districts = [
                  'Gombak',
                  'Petaling',
                  'Hulu Langat',
                  'Hulu Selangor',
                  'Kuala Langat',
                  'Kuala Selangor',
                  'Sabak Bernam',
                  'Klang',
                  'Sepang',
                ];

                // Real images from the selangor.travel website that showcase landmarks from each district
                final districtImages = [
                  'https://selangor.travel/wp-content/uploads/2017/04/Gombak_Batu_Caves_Temple.jpeg', // Gombak
                  'https://selangor.travel/wp-content/uploads/2017/04/Petaling-Blue_Mosque.jpg.webp', // Petaling
                  'https://selangor.travel/wp-content/uploads/2017/04/Hulu_Langat_Sate.jpg', // Hulu Langat
                  'https://selangor.travel/wp-content/uploads/2017/04/Hulu_Selangor_White_water_Rafting.jpg', // Hulu Selangor
                  'https://selangor.travel/wp-content/uploads/2017/04/Kuala_Langat_Mahmeri.jpg', // Kuala Langat
                  'https://selangor.travel/wp-content/uploads/2017/04/Rumah_Api_Bukit_Malawati.jpg', // Kuala Selangor
                  'https://selangor.travel/wp-content/uploads/2017/04/Sawah_Padi_Sabak_Bernam.jpg', // Sabak Bernam
                  'https://selangor.travel/wp-content/uploads/2017/04/Galeri_Diraja_Sultan_Abdul_Aziz.jpg', // Klang
                  'https://selangor.travel/wp-content/uploads/2017/04/Sepang_SIC.jpg', // Sepang
                ];

                return _buildDistrictItem(
                  context,
                  districts[index],
                  districtImages[index],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Featured Restaurants - Location-based Recommendations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle(
              title: "Recommended For You",
              actionText: "See All",
              onActionTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('More recommendations coming soon!')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Featured restaurants horizontal list
          SizedBox(
            height: 100,
            child: _isLoadingRestaurants || _userLocation == null
                ? const Center(child: CircularProgressIndicator())
                : _featuredRestaurants.isEmpty
                    ? const Center(child: Text('No recommendations available'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: _featuredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = _featuredRestaurants[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to restaurant detail screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RestaurantDetailScreen(
                                      restaurantId: restaurant.id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 260,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Restaurant image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                      child: Image.asset(
                                        restaurant.photos.isNotEmpty
                                            ? restaurant.photos[0]
                                            : 'assets/images/placeholder_food.jpg',
                                        width: 80,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Restaurant info
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Name with rating
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    restaurant.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      restaurant.rating
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            // Cuisine
                                            Text(
                                              restaurant.cuisineTypes
                                                  .join(', '),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Location with trending icon
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.trending_up,
                                                  size: 14,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Popular nearby',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 24),

          // Nearby Restaurants Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle(
              title: "Nearby Restaurants",
              actionText: "See All",
              onActionTap: () {
                // Navigate to see all nearby restaurants
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('See all nearby coming soon!')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Nearby Restaurants List
          SizedBox(
            height: 250,
            child: _isLoadingRestaurants || _userLocation == null
                ? const Center(child: CircularProgressIndicator())
                : _nearbyRestaurants.isEmpty
                    ? const Center(child: Text('No restaurants found nearby'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: _nearbyRestaurants.length > 5
                            ? 5
                            : _nearbyRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = _nearbyRestaurants[index];
                          String distanceText = 'Nearby';
                          if (_userLocation != null) {
                            distanceText = DistanceUtils.getDistanceString(
                              _userLocation!,
                              restaurant.location,
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 230,
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to restaurant detail screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailScreen(
                                        restaurantId: restaurant.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image
                                      SizedBox(
                                        height: 120,
                                        width: double.infinity,
                                        child: Image.asset(
                                          restaurant.photos.isNotEmpty
                                              ? restaurant.photos[0]
                                              : 'assets/images/placeholder_food.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Name
                                            Text(
                                              restaurant.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Cuisine
                                            Text(
                                              restaurant.cuisineTypes
                                                  .join(', '),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            // Rating and distance
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Rating
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      restaurant.rating
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                // Distance
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.grey,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      distanceText,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationContainer(
      BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictItem(BuildContext context, String name, String image) {
    return GestureDetector(
      onTap: () {
        // Navigate to district detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DistrictDetailScreen(
              districtName: name,
              imageUrl: image,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: SizedBox(
                height: 80,
                width: 80,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 80,
                      width: 80,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              'Selangor',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Promotional carousel removed as requested
}

/// Explore tab content
class _ExploreContent extends StatefulWidget {
  const _ExploreContent({Key? key}) : super(key: key);

  @override
  State<_ExploreContent> createState() => _ExploreContentState();
}

class _ExploreContentState extends State<_ExploreContent> {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _searchResults = [];
  bool _isSearching = false;
  String? _locationFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchRestaurants(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _restaurantService.searchRestaurants(
        query: query,
        locationFilter: _locationFilter,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching restaurants: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0,
          80.0), // Added extra bottom padding for navigation bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar with location filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for restaurants, cuisine...',
                    prefixIcon:
                        Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchRestaurants('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: _searchRestaurants,
                ),
                const SizedBox(height: 8),
                // Location filter chip
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 4),
                        child: Text(
                          'Filter by:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      FilterChip(
                        label: Text(_locationFilter ?? 'Location'),
                        selected: _locationFilter != null,
                        avatar: const Icon(Icons.location_on, size: 18),
                        onSelected: (selected) {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) => _buildLocationFilterSheet(),
                          );
                        },
                      ),
                      if (_locationFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ActionChip(
                            label: const Text('Clear Filters'),
                            avatar: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _locationFilter = null;
                              });
                              if (_searchController.text.isNotEmpty) {
                                _searchRestaurants(_searchController.text);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Categories (horizontal scroll)
          const SectionTitle(title: 'Browse by Cuisine'),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryItem(context, 'Burgers', Icons.lunch_dining),
                _buildCategoryItem(context, 'Pizza', Icons.local_pizza),
                _buildCategoryItem(context, 'Asian', Icons.ramen_dining),
                _buildCategoryItem(context, 'Dessert', Icons.icecream),
                _buildCategoryItem(context, 'Healthy', Icons.spa),
                _buildCategoryItem(context, 'Drinks', Icons.local_cafe),
                _buildCategoryItem(context, 'Seafood', Icons.set_meal),
                _buildCategoryItem(context, 'More', Icons.more_horiz),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // List of restaurants
          const SectionTitle(title: 'All Restaurants'),
          if (_searchController.text.isNotEmpty)
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? const Center(child: Text('No restaurants found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final restaurant = _searchResults[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  restaurant.photos.isNotEmpty
                                      ? restaurant.photos[0]
                                      : 'assets/images/placeholder_food.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(restaurant.name),
                              subtitle: Text(
                                '${restaurant.cuisineTypes.join(', ')} • ${restaurant.address}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(restaurant.rating.toStringAsFixed(1)),
                                ],
                              ),
                              onTap: () {
                                // Show restaurant details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Viewing ${restaurant.name} details')),
                                );
                              },
                            );
                          },
                        ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 10, // Replace with actual data
              itemBuilder: (context, index) {
                return RestaurantListItem(
                  name: 'Restaurant ${index + 1}',
                  image:
                      'https://via.placeholder.com/150', // Replace with actual image
                  rating: 4.0 + (index % 10) / 10,
                  cuisine: index % 2 == 0 ? 'Asian' : 'Western',
                  location: 'Shah Alam',
                  distance: '${(index + 1) * 0.5} km',
                  isFavorite: index % 3 == 0,
                  onTap: () {
                    // TODO: Navigate to restaurant details
                  },
                  onFavoriteToggle: () {
                    // TODO: Toggle favorite status
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a location filter',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Shah Alam'),
            onTap: () {
              setState(() {
                _locationFilter = 'Shah Alam';
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Petaling Jaya'),
            onTap: () {
              setState(() {
                _locationFilter = 'Petaling Jaya';
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Kuala Lumpur'),
            onTap: () {
              setState(() {
                _locationFilter = 'Kuala Lumpur';
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Section title widget
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? viewAll;
  final VoidCallback? onActionTap;
  final String? actionText;

  const SectionTitle({
    Key? key,
    required this.title,
    this.viewAll,
    this.onActionTap,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GradientTitle(
            text: title,
            fontSize: 18,
          ),
          if (viewAll != null)
            TextButton(
              onPressed: viewAll,
              child: const Text('View All'),
            ),
          if (onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(actionText ?? ''),
            ),
        ],
      ),
    );
  }
}

/// Restaurant card widget
class RestaurantCard extends StatelessWidget {
  final String name;
  final String image;
  final double rating;
  final String cuisine;
  final String location;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const RestaurantCard({
    Key? key,
    required this.name,
    required this.image,
    required this.rating,
    required this.cuisine,
    required this.location,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                image,
                height: 120,
                width: 180,
                fit: BoxFit.cover,
              ),
            ),

            // Restaurant info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Cuisine
                  Text(
                    cuisine,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textColorSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Rating and location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),

                      // Location
                      Text(
                        location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textColorSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Restaurant list item widget
class RestaurantListItem extends StatelessWidget {
  final String name;
  final String image;
  final double rating;
  final String cuisine;
  final String location;
  final String distance;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const RestaurantListItem({
    Key? key,
    required this.name,
    required this.image,
    required this.rating,
    required this.cuisine,
    required this.location,
    required this.distance,
    this.isFavorite = false,
    required this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Restaurant image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  image,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Restaurant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Cuisine
                    Text(
                      cuisine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textColorSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Rating and distance
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Distance
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.textColorSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              distance,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textColorSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite button
              if (onFavoriteToggle != null)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: onFavoriteToggle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
