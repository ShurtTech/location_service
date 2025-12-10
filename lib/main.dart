import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracking/app_router.dart';
import 'package:location_tracking/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  developer.log('🚀 App starting...', name: 'Main');
  print('🚀 App starting...');

  try {
    // Initialize dependency injection
    await di.init();
    developer.log('✅ Dependency injection initialized', name: 'Main');
    print('✅ Dependency injection initialized');

    runApp(MyApp());
  } catch (e, stackTrace) {
    developer.log(
      '❌ App initialization failed',
      name: 'Main',
      error: e,
      stackTrace: stackTrace,
    );
    print('❌ App initialization failed: $e');
    
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error initializing app'),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        _appRouter.replace(const LocationTrackingRoute());
      }
    } catch (e) {
      developer.log('Error checking initial route: $e', name: 'Main');
      print('Error checking initial route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HRM App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
