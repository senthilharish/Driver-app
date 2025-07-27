
import 'package:driver_application/services/auth_managementService.dart';
import 'package:driver_application/services/location_managementService.dart';
import 'package:driver_application/ui/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'bus_entry_screen.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  bool _isStoppingTracking = false;

  @override
  void initState() {
    super.initState();
    // Move to current location when position updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToCurrentLocation();
    });
  }

  void _moveToCurrentLocation() {
    final locationService = context.read<LocationManagementService>();
    if (locationService.currentPosition != null) {
      final position = locationService.currentPosition!;
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16.0,
      );
    }
  }

  Future<void> _stopTracking() async {
    setState(() {
      _isStoppingTracking = true;
    });

    try {
      final locationService = context.read<LocationManagementService>();
      await locationService.stopTracking();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BusEntryScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping tracking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStoppingTracking = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    // Stop tracking first
    final locationService = context.read<LocationManagementService>();
    if (locationService.isTracking) {
      await locationService.stopTracking();
    }

    try {
      final authService = context.read<AuthManagementService>();
      await authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocationManagementService>(
          builder: (context, locationService, child) {
            return Text('Bus ${locationService.currentBusNumber ?? ''}');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LocationManagementService>(
        builder: (context, locationService, child) {
          if (locationService.currentPosition == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting location...'),
                ],
              ),
            );
          }

          final position = locationService.currentPosition!;
          final currentLatLng = LatLng(position.latitude, position.longitude);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLatLng,
                  initialZoom: 16.0,
                  minZoom: 3.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.bus_tracking_admin',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLatLng,
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Current Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Lat: ${position.latitude.toStringAsFixed(6)}'),
                        Text('Lng: ${position.longitude.toStringAsFixed(6)}'),
                        Text('Accuracy: ${position.accuracy.toStringAsFixed(1)}m'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: locationService.isTracking 
                                    ? Colors.green 
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              locationService.isTracking 
                                  ? 'Tracking Active' 
                                  : 'Tracking Stopped',
                              style: TextStyle(
                                color: locationService.isTracking 
                                    ? Colors.green 
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Stop Tracking',
                      isLoading: _isStoppingTracking,
                      onPressed: _stopTracking,
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}