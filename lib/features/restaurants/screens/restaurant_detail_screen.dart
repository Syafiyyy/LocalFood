import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/restaurant.dart';
import '../repositories/restaurant_repository.dart';
import '../services/saved_restaurant_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Restaurant restaurant;
  bool _isLoading = true;
  bool _isSaved = false;
  final SavedRestaurantService _savedRestaurantService = SavedRestaurantService();

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    final RestaurantRepository repository = RestaurantRepository();
    final Restaurant? loadedRestaurant =
        repository.getRestaurantById(widget.restaurantId);

    if (loadedRestaurant != null) {
      // Check if restaurant is saved in Firestore
      bool isSaved = false;
      try {
        isSaved = await _savedRestaurantService.isRestaurantSaved(loadedRestaurant.id);
      } catch (e) {
        // If there's an error checking saved status, assume not saved
        isSaved = false;
      }
      
      if (mounted) {
        setState(() {
          restaurant = loadedRestaurant;
          _isSaved = isSaved;
          _isLoading = false;
        });
      }
    } else {
      // Handle restaurant not found
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildImageCarousel(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantInfo(),
                    const SizedBox(height: 24),
                    _buildDescription(),
                    const SizedBox(height: 24),
                    _buildLocation(),
                    const SizedBox(height: 24),
                    _buildHours(),
                    const SizedBox(height: 24),
                    _buildFeatures(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 56.0,
      floating: true,
      pinned: true,
      title: Text(
        restaurant.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppTheme.primaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Share functionality
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 250,
      color: Colors.grey[200],
      child: restaurant.photos.isEmpty
          ? _buildImagePlaceholder()
          : PageView.builder(
              itemCount: restaurant.photos.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  restaurant.photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                );
              },
            ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              color: AppTheme.primaryColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              restaurant.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rating.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: restaurant.cuisineTypes.map((type) {
            return Chip(
              label: Text(type),
              backgroundColor: Colors.grey[200],
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                restaurant.address,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        if (restaurant.phoneNumber != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InkWell(
              onTap: () async {
                final Uri phoneUri = Uri(
                  scheme: 'tel',
                  path: restaurant.phoneNumber,
                );
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    restaurant.phoneNumber!,
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        if (restaurant.website != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InkWell(
              onTap: () async {
                final Uri websiteUri = Uri.parse(restaurant.website!);
                if (await canLaunchUrl(websiteUri)) {
                  await launchUrl(websiteUri);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.public, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Website',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About'),
        const SizedBox(height: 8),
        Text(
          restaurant.description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Map controller for zoom functionality
  final MapController _mapController = MapController();

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Location'),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Actual map display with enabled interactions
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(restaurant.location.latitude,
                        restaurant.location.longitude),
                    zoom: 15.0,
                    // Enable map interactions
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.localicious.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(restaurant.location.latitude,
                              restaurant.location.longitude),
                          width: 80,
                          height: 80,
                          builder: (context) => Icon(
                            Icons.location_on,
                            color: AppTheme.primaryColor,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Zoom controls
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "btn_zoom_in",
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final currentZoom = _mapController.zoom;
                          _mapController.move(
                              LatLng(restaurant.location.latitude,
                                  restaurant.location.longitude),
                              currentZoom + 1);
                        },
                        child: const Icon(
                          Icons.add,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "btn_zoom_out",
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final currentZoom = _mapController.zoom;
                          _mapController.move(
                              LatLng(restaurant.location.latitude,
                                  restaurant.location.longitude),
                              currentZoom - 1);
                        },
                        child: const Icon(
                          Icons.remove,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Google Maps button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: "btn_google_maps",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${restaurant.location.latitude},${restaurant.location.longitude}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: const Icon(
                      Icons.map,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Hours'),
        const SizedBox(height: 8),
        ...restaurant.hours.entries.map((entry) {
          final bool isToday = _isToday(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? AppTheme.primaryColor : Colors.black,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekday = now.weekday;

    final Map<int, String> weekdayMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    return weekdayMap[weekday] == day;
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Features'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: restaurant.features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(feature),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Expanded(
          child: Divider(
            indent: 16,
            thickness: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                // Handle save/unsave
                try {
                  if (_isSaved) {
                    // Remove from saved restaurants
                    await _savedRestaurantService.removeRestaurant(restaurant.id);
                    setState(() {
                      _isSaved = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restaurant removed from saved list')),
                      );
                    }
                  } else {
                    // Add to saved restaurants
                    await _savedRestaurantService.saveRestaurant(restaurant);
                    setState(() {
                      _isSaved = true;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restaurant saved')),
                      );
                    }
                  }
                } catch (e) {
                  // Show error
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
              label: Text(_isSaved ? 'Saved' : 'Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                // Use restaurant address for a more user-friendly Google Maps experience
                final String encodedAddress =
                    Uri.encodeComponent(restaurant.address);
                final String encodedName = Uri.encodeComponent(restaurant.name);

                // Also include coordinates as backup if the address isn't found
                final lat = restaurant.location.latitude;
                final lng = restaurant.location.longitude;

                // Use address + name for the search, which is more user-friendly
                final String mapUrl =
                    'https://www.google.com/maps/search/$encodedName+$encodedAddress';

                try {
                  // Open with platform default - most reliable approach
                  await launchUrl(Uri.parse(mapUrl),
                      mode: LaunchMode.platformDefault);
                } catch (e) {
                  // Fallback to coordinates if address search fails
                  try {
                    final String backupUrl =
                        'https://www.google.com/maps?q=$lat,$lng';
                    await launchUrl(Uri.parse(backupUrl),
                        mode: LaunchMode.platformDefault);
                  } catch (e) {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Could not open Google Maps. Please check if you have a browser installed.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.directions),
              label: const Text('Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
