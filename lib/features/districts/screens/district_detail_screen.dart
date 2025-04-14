import 'package:flutter/material.dart';
import 'package:group_project/core/theme/app_theme.dart';
import 'package:group_project/features/districts/widgets/district_map.dart';
import 'package:group_project/features/restaurants/models/restaurant.dart';
import 'package:group_project/features/restaurants/repositories/restaurant_repository.dart';
import 'package:group_project/features/restaurants/screens/restaurant_detail_screen.dart';

class DistrictDetailScreen extends StatefulWidget {
  final String districtName;
  final String imageUrl;

  const DistrictDetailScreen({
    Key? key,
    required this.districtName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<DistrictDetailScreen> createState() => _DistrictDetailScreenState();
}

class _DistrictDetailScreenState extends State<DistrictDetailScreen> {
  late ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 180 && !_showTitle) {
      setState(() {
        _showTitle = true;
      });
    } else if (_scrollController.offset <= 180 && _showTitle) {
      setState(() {
        _showTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            title: _showTitle ? Text(widget.districtName) : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // District Image
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // District name at the bottom of the image
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      widget.districtName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  _buildSectionHeader('About'),
                  const SizedBox(height: 8),
                  Text(
                    _getDistrictDescription(widget.districtName),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // District Map Section
                  _buildSectionHeader('District Map'),
                  const SizedBox(height: 12),
                  DistrictMap(districtName: widget.districtName),
                  const SizedBox(height: 24),

                  // Restaurants to try
                  _buildSectionHeader('Restaurants to Try'),
                  const SizedBox(height: 12),
                  _buildRestaurantsList(widget.districtName),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSectionIcon(title),
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'About':
        return Icons.info_outline;
      case 'Popular Attractions':
        return Icons.attractions;
      case 'Restaurants to Try':
        return Icons.restaurant;
      case 'District Map':
        return Icons.map;
      default:
        return Icons.circle;
    }
  }

  Widget _buildRestaurantsList(String districtName) {
    final restaurantRepo = RestaurantRepository();
    List<Restaurant> restaurants = [];
    
    // Use the same method as the map to get district-specific restaurants
    restaurants = restaurantRepo.getRestaurantsByDistrict(districtName);
    
    // Print for debugging
    print('Found ${restaurants.length} restaurants for $districtName in restaurant list');

    if (restaurants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants available yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re working on adding great local restaurants for this district. Check back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: restaurants.map((restaurant) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(
                    restaurantId: restaurant.id,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Restaurant image or placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: restaurant.photos.isNotEmpty
                          ? null
                          : AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      image: restaurant.photos.isNotEmpty
                          ? DecorationImage(
                              image: AssetImage(restaurant.photos[0]),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: restaurant.photos.isEmpty
                        ? const Icon(
                            Icons.restaurant,
                            color: AppTheme.primaryColor,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Restaurant details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            Text(
                              ' ${restaurant.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${restaurant.cuisineTypes.isNotEmpty ? restaurant.cuisineTypes[0] : "Various"} • ',
                            ),
                            Text(
                              restaurant.priceLevel ?? "\$",
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDistrictDescription(String districtName) {
    switch (districtName) {
      case 'Gombak':
        return 'Gombak is known for its stunning natural landscape and cultural landmarks. Home to the famous Batu Caves limestone hill with its temple complex, it\'s also where you\'ll find natural gems like the Kanching Rainforest Waterfall and the Commonwealth Forest Park.';
      case 'Petaling':
        return 'Petaling district includes parts of the bustling city of Petaling Jaya and is famous for its shopping malls, entertainment venues, and the iconic Sultan Salahuddin Abdul Aziz Shah Mosque (Blue Mosque), one of the largest mosques in Southeast Asia.';
      case 'Hulu Langat':
        return 'Hulu Langat offers a refreshing escape with its pristine rivers, waterfalls, and cool hillside towns like Hulu Langat Town and Kajang. It\'s renowned for its satay, natural hot springs, and the tranquil Semenyih Dam surrounded by lush tropical forest.';
      case 'Hulu Selangor':
        return 'Hulu Selangor is a highland paradise known for its mountains, rivers, and adventure activities. Visitors flock to experience white water rafting in Kuala Kubu Bharu, explore the Chiling Waterfall, or enjoy the cooler climate of Fraser\'s Hill just on its border.';
      case 'Kuala Langat':
        return 'Kuala Langat is a coastal district with rich biodiversity including mangrove forests, firefly sanctuaries, and the Carey Island, home to the indigenous Mah Meri tribe known for their intricate wood carvings and cultural heritage.';
      case 'Kuala Selangor':
        return 'Kuala Selangor is famous for its historical lighthouse at Bukit Malawati, evening firefly watching along the Selangor River, and fresh seafood. The Kuala Selangor Nature Park is a haven for migratory birds and silver-leaf monkeys.';
      case 'Sabak Bernam':
        return 'Sabak Bernam is a peaceful agricultural district renowned for its vast paddy fields creating picturesque rural landscapes. The district offers authentic fishing village experiences, tranquil beaches, and the historic Sungai Haji Dorani Homestay village.';
      case 'Klang':
        return 'Klang is one of Malaysia\'s oldest cities and the royal town of Selangor. It\'s renowned for its rich heritage sites including the Sultan Abdul Aziz Royal Gallery, Klang Palace, and colonial architecture. The district is also famous for its exceptional seafood and vibrant Little India area.';
      case 'Sepang':
        return 'Sepang is home to the Sepang International Circuit, which hosts major motorsport events, and the Kuala Lumpur International Airport. The district also boasts beautiful beaches at Gold Coast Sepang and Bagan Lalang, making it a diverse destination for visitors.';
      default:
        return 'A beautiful district in Selangor with its own unique cultural heritage, natural attractions, and delicious local cuisine waiting to be explored.';
    }
  }
}
