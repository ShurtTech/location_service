import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_tracking/app_router.dart';
import 'package:location_tracking/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 App starting...');

  try {
    await di.init();
    print('✅ Dependency injection initialized');

    runApp(MyApp());
  } catch (e) {
    print('❌ App initialization failed: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $e')),
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      _appRouter.replace(const LocationTrackingRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with WithForegroundTask for foreground service support
    return WithForegroundTask(
      child: MaterialApp.router(
        title: 'Location Tracking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }
}
