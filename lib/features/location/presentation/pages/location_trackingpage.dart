import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location_tracking/app_router.dart';
import 'package:location_tracking/core/constants/app_colours.dart';
import 'package:location_tracking/core/constants/app_textstyles.dart';
import 'package:location_tracking/core/services/simple_location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> with WidgetsBindingObserver {
  String? _userEmail;
  int _locationCount = 0;
  bool _isTracking = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadLocationCount();
    _checkTrackingStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 App lifecycle state: $state');
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email');
    });
  }

  Future<void> _loadLocationCount() async {
    final history = await SimpleLocationTracker.getLocationHistory();
    if (mounted) {
      setState(() {
        _locationCount = history.length;
      });
    }
  }

  Future<void> _checkTrackingStatus() async {
    final isTracking = await SimpleLocationTracker.isTracking();
    if (mounted) {
      setState(() {
        _isTracking = isTracking;
      });
    }
  }

  Future<void> _toggleTracking() async {
    setState(() => _isLoading = true);

    try {
      if (_isTracking) {
        await SimpleLocationTracker.stopTracking();
        if (mounted) {
          setState(() => _isTracking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location tracking stopped'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('auth_token') ?? '';
        
        await SimpleLocationTracker.startTracking(authToken);
        
        if (mounted) {
          setState(() => _isTracking = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location tracking started - Check console for updates every 5 seconds'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      
      await _loadLocationCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _viewLocationHistory() async {
    final history = await SimpleLocationTracker.getLocationHistory();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history, color: AppColours.primaryColor),
            SizedBox(width: 8),
            Text('Location History'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No location history'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final location = history[history.length - 1 - index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColours.primaryColor,
                          child: Text(
                            '${history.length - index}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          '${location['latitude']}, ${location['longitude']}',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              '${location['timestamp']}'.substring(0, 19),
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Accuracy: ${location['accuracy'].toStringAsFixed(1)}m',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await SimpleLocationTracker.clearLocationHistory();
              Navigator.pop(context);
              _loadLocationCount();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('History cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? Location tracking will be stopped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await SimpleLocationTracker.stopTracking();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');

      if (mounted) {
        context.router.replace(const LoginRoute());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Location Tracking'),
        backgroundColor: AppColours.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _viewLocationHistory,
            tooltip: 'History',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColours.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: AppColours.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail ?? 'User',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isTracking
                      ? [Colors.green, Colors.green.shade700]
                      : [Colors.grey.shade400, Colors.grey.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_isTracking ? Colors.green : Colors.grey)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isTracking ? Icons.gps_fixed : Icons.gps_off,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isTracking
                        ? 'Location Tracking Active'
                        : 'Location Tracking Inactive',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isTracking
                        ? 'Updating every 5 seconds in console'
                        : 'Start tracking to monitor location',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isTracking) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            '$_locationCount locations recorded',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Control Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleTracking,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(_isTracking ? Icons.stop : Icons.play_arrow, size: 24),
                label: Text(
                  _isLoading
                      ? 'Please wait...'
                      : _isTracking
                          ? 'Stop Tracking'
                          : 'Start Tracking',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
