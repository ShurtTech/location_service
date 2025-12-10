import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location_tracking/app_router.dart';
import 'package:location_tracking/core/constants/app_colours.dart';
import 'package:location_tracking/core/constants/app_textstyles.dart';
import 'package:location_tracking/core/services/simple_location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

@RoutePage()
class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> 
    with WidgetsBindingObserver {
  String? _userEmail;
  int _locationCount = 0;
  bool _isTracking = false;
  bool _isLoading = false;
  Timer? _locationCountTimer;
  String _appState = 'Active';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadLocationCount();
    _checkTrackingStatus();
    
    // Start timer to refresh location count every 2 seconds
    _locationCountTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isTracking) {
        _loadLocationCount();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationCountTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 App lifecycle state: $state');
    
    if (mounted) {
      setState(() {
        switch (state) {
          case AppLifecycleState.resumed:
            _appState = 'Active (Foreground)';
            break;
          case AppLifecycleState.inactive:
            _appState = 'Inactive';
            break;
          case AppLifecycleState.paused:
            _appState = 'Paused (Background)';
            break;
          case AppLifecycleState.detached:
            _appState = 'Detached';
            break;
          case AppLifecycleState.hidden:
            _appState = 'Hidden';
            break;
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userEmail = prefs.getString('user_email');
      });
    }
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
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.stop_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Location tracking stopped',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Foreground service disabled',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Location tracking started',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Running as foreground service • Works after clearing recents',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
      
      await _loadLocationCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        e.toString(),
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
            Expanded(child: Text('Location History')),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColours.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${history.length}',
                style: TextStyle(
                  color: AppColours.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
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
                      Text(
                        'No location history',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start tracking to see locations',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final location = history[history.length - 1 - index];
                    final timestamp = location['timestamp'] as DateTime;
                    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
                        '${timestamp.minute.toString().padLeft(2, '0')}:'
                        '${timestamp.second.toString().padLeft(2, '0')}';
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColours.primaryColor,
                          child: Text(
                            '${history.length - index}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '📍 ${location['latitude'].toStringAsFixed(6)}, '
                          '${location['longitude'].toStringAsFixed(6)}',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 12),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  timeStr,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.my_location, size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '${location['accuracy'].toStringAsFixed(1)}m',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.speed, size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '${(location['speed'] * 3.6).toStringAsFixed(1)} km/h',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.map, color: AppColours.primaryColor),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Maps: ${location['latitude']}, ${location['longitude']}'
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (history.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear History?'),
                    content: Text(
                      'This will permanently delete ${history.length} location records.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await SimpleLocationTracker.clearLocationHistory();
                  Navigator.pop(context);
                  _loadLocationCount();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('History cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: Icon(Icons.delete_sweep),
              label: Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to logout?'),
            SizedBox(height: 12),
            if (_isTracking)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location tracking will be stopped',
                        style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      // Stop tracking first
      if (_isTracking) {
        await SimpleLocationTracker.stopTracking();
      }

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');

      if (mounted) {
        context.router.replace(const LoginRoute());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Logged out successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
        elevation: 0,
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
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail ?? 'User',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // App State Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _appState.contains('Active') ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _appState.contains('Active') 
                      ? Colors.green.shade200 
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _appState.contains('Active') ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'App Status: $_appState',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _appState.contains('Active') 
                            ? Colors.green.shade900 
                            : Colors.orange.shade900,
                      ),
                    ),
                  ),
                  if (_isTracking)
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.green,
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
                        ? 'Foreground Service Running\nUpdating every 5 seconds'
                        : 'Start tracking to monitor location',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isTracking) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip(
                          icon: Icons.location_on,
                          label: '$_locationCount',
                          sublabel: 'Locations',
                        ),
                        _buildStatChip(
                          icon: Icons.timer,
                          label: '5s',
                          sublabel: 'Interval',
                        ),
                        _buildStatChip(
                          icon: Icons.shield,
                          label: 'BG',
                          sublabel: 'Service',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Card - UPDATED
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isTracking ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isTracking ? Colors.green.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isTracking ? Icons.check_circle : Icons.info_outline,
                    color: _isTracking ? Colors.green : Colors.blue,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isTracking
                          ? '✓ Foreground service is active\n✓ Works even after clearing from recents\n✓ Notifications show each update'
                          : 'Uses Android Foreground Service for reliable background tracking. '
                            'Check notifications for location updates.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isTracking ? Colors.green.shade900 : Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

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
                    : Icon(
                        _isTracking ? Icons.stop : Icons.play_arrow, 
                        size: 24,
                      ),
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
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
