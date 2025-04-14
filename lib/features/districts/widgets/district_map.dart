import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../restaurants/repositories/restaurant_repository.dart';
import '../../restaurants/screens/restaurant_detail_screen.dart';

class DistrictMap extends StatefulWidget {
  final String districtName;
  final double height;

  const DistrictMap({
    Key? key,
    required this.districtName,
    this.height = 250,
  }) : super(key: key);

  @override
  State<DistrictMap> createState() => _DistrictMapState();
}

class _DistrictMapState extends State<DistrictMap>
    with SingleTickerProviderStateMixin {
  List<Polygon> _polygons = [];
  LatLng _center = LatLng(3.1, 101.5); // Default center (Selangor)
  bool _isLoading = true;
  final MapController _mapController = MapController();
  bool _isFullScreen = false;
  late AnimationController _animationController;
  final List<String> _mapStyles = [
    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  ];
  int _currentMapStyleIndex = 0;
  double _zoomLevel = 11.0;
  // Add restaurant markers
  List<Marker> _restaurantMarkers = [];
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Load GeoJSON first
    _loadGeoJson();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadGeoJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/selangor_districts.json');
      final dynamic geojsonData = json.decode(jsonString);
      final features = geojsonData['features'] as List;

      List<Polygon> polygons = [];
      bool districtFound = false;

      // First, find the selected district and its polygon points
      for (var feature in features) {
        final properties = feature['properties'];
        final name = properties['name'] as String;

        // Match the district name (case insensitive)
        if (widget.districtName.toLowerCase() == name.toLowerCase()) {
          districtFound = true;

          final geometry = feature['geometry'];
          final coordinates = geometry['coordinates'] as List;

          // Handle different geometry types
          List polygonCoordinates;
          if (geometry['type'] == 'MultiPolygon') {
            polygonCoordinates = coordinates[0][0] as List;
          } else {
            polygonCoordinates = coordinates[0] as List;
          }

          // Convert GeoJSON coordinates to LatLng
          List<LatLng> polygonPoints = [];
          for (var point in polygonCoordinates) {
            // GeoJSON format is [longitude, latitude]
            polygonPoints.add(LatLng(point[1], point[0]));
          }

          // Add the polygon to the map
          polygons.add(
            Polygon(
              points: polygonPoints,
              color: AppTheme.primaryColor.withOpacity(0.3),
              borderColor: AppTheme.primaryColor.withOpacity(0.7),
              borderStrokeWidth: 2,
            ),
          );

          // Set the map center to the center of the district polygon
          _calculateCenter(polygonPoints);
          break;
        }
      }

      // If we didn't find the district, use default center
      if (!districtFound) {
        _center = LatLng(3.1, 101.5); // Default center (Selangor)
      }

      setState(() {
        _polygons = polygons;
        _isLoading = false;
      });

      // Now load restaurant markers after centering the map
      _loadRestaurantMarkers();
    } catch (e) {
      print('Error loading GeoJSON: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    // Calculate center using bounds for more accurate positioning
    _center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    // Calculate zoom level based on district size
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;

    // Use a lower default zoom level for larger districts
    _zoomLevel = 10.0;

    // Adjust zoom based on district size
    if (latDiff > 0.3 || lngDiff > 0.3) {
      _zoomLevel = 9.5;
    } else if (latDiff < 0.15 && lngDiff < 0.15) {
      _zoomLevel = 11.0;
    }
  }

  void _loadRestaurantMarkers() {
    // Get restaurants specific to this district using our new method
    final districtRestaurants = _restaurantRepository.getRestaurantsByDistrict(widget.districtName);
    List<Marker> markers = [];
    
    // Log the number of restaurants found for debugging
    print('Found ${districtRestaurants.length} restaurants for ${widget.districtName}');
    
    // Create markers for each restaurant in this district
    for (var restaurant in districtRestaurants) {

      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: restaurant.location,
          builder: (ctx) => GestureDetector(
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    restaurant.name.length > 15
                        ? '${restaurant.name.substring(0, 15)}...'
                        : restaurant.name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      _restaurantMarkers = markers;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _zoomIn() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom + 0.5);
  }

  void _zoomOut() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom - 0.5);
  }

  void _changeMapStyle() {
    setState(() {
      _currentMapStyleIndex = (_currentMapStyleIndex + 1) % _mapStyles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: _isFullScreen
              ? MediaQuery.of(context).size.height * 0.7
              : widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading Map...',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _center,
                        zoom: _zoomLevel,
                        minZoom: 7.0,
                        maxZoom: 15.0,
                        interactiveFlags: InteractiveFlag.all,
                        onMapReady: () {
                          // Center map on district when ready
                          _mapController.move(_center, _zoomLevel);
                        },
                      ),
                      children: [
                        // Tile Layer with custom style
                        TileLayer(
                          urlTemplate: _mapStyles[_currentMapStyleIndex],
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.localicious.app',
                          backgroundColor: const Color(0xFFE0F2F1),
                          tileProvider: NetworkTileProvider(),
                          maxZoom: 18,
                          // Add some fadeIn for a smoother experience
                          tileBuilder: (context, child, tile) {
                            return AnimatedOpacity(
                              opacity:
                                  1.0, // Always fully visible in this version
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: child,
                            );
                          },
                        ),

                        // District polygons with custom styling
                        PolygonLayer(
                          polygons: _polygons,
                        ),

                        // District center marker
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _center,
                              width: 60,
                              height: 60,
                              builder: (context) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryColor,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Restaurant markers
                        MarkerLayer(
                          markers: _restaurantMarkers,
                        ),

                        // Attribution with custom styling
                        RichAttributionWidget(
                          alignment: AttributionAlignment.bottomLeft,
                          attributions: [
                            TextSourceAttribution(
                              'Map data OpenStreetMap',
                              textStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Map Controls
                    Positioned(
                      right: 16,
                      top: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Zoom in control
                            MapButton(
                              icon: Icons.add,
                              onPressed: _zoomIn,
                              tooltip: 'Zoom In',
                            ),
                            const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFEEEEEE)),
                            // Zoom out control
                            MapButton(
                              icon: Icons.remove,
                              onPressed: _zoomOut,
                              tooltip: 'Zoom Out',
                            ),
                            const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFEEEEEE)),
                            // Map style switcher
                            MapButton(
                              icon: Icons.layers,
                              onPressed: _changeMapStyle,
                              tooltip: 'Change Map Style',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Info button at bottom left
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (_isFullScreen)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: _toggleFullScreen,
              icon: const Icon(Icons.fullscreen_exit),
              label: const Text('Exit Fullscreen'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side:
                      BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MapButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customChild;
  final VoidCallback onPressed;
  final String tooltip;

  const MapButton({
    Key? key,
    this.icon,
    this.customChild,
    required this.onPressed,
    required this.tooltip,
  })  : assert(icon != null || customChild != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: AppTheme.primaryColor.withOpacity(0.3),
            highlightColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: customChild ??
                  Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
