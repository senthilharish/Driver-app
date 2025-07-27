
import 'package:driver_application/services/auth_managementService.dart';
import 'package:driver_application/services/location_managementService.dart' show LocationManagementService;
import 'package:driver_application/ui/custom_button.dart';
import 'package:driver_application/ui/livemap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class BusEntryScreen extends StatefulWidget {
  const BusEntryScreen({super.key});

  @override
  State<BusEntryScreen> createState() => _BusEntryScreenState();
}

class _BusEntryScreenState extends State<BusEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  bool _isStarting = false;

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isStarting = true;
      });

      try {
        final locationService = context.read<LocationManagementService>();
        final authService = context.read<AuthManagementService>();

        await locationService.startTracking(
          busNumber: _busNumberController.text.trim().toUpperCase(),
          driverId: authService.driverId!,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LiveMapScreen(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isStarting = false;
          });
        }
      }
    }
  }

  Future<void> _logout() async {
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
        title: const Text('Bus Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.directions_bus,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter Bus Details',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Consumer<AuthManagementService>(
                  builder: (context, authService, child) {
                    return Text(
                      'Welcome, ${authService.user?.email ?? 'Driver'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _busNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Bus Number',
                    prefixIcon: Icon(Icons.directions_bus),
                    border: OutlineInputBorder(),
                    hintText: 'e.g.15',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bus number';
                    }
                    if (value.trim().length <1) {
                      return 'Bus number must be at least 1 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Start Tracking',
                  isLoading: _isStarting,
                  onPressed: _startTracking,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}