import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:location_tracking/features/location/presentation/pages/location_trackingpage.dart';
import 'package:location_tracking/features/location/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Auth Routes
        AutoRoute(
          page: LoginRoute.page,
          initial: true,
          path: '/login',
        ),
        
        // Main App Routes
        // AutoRoute(
        //   page: HomeRoute.page,
        //   path: '/home',
        //   guards: [AuthGuard()],
        // ),
        AutoRoute(
          page: LocationTrackingRoute.page,
          path: '/location-tracking',
          guards: [AuthGuard()],
        ),
        
        // Other routes...
        // AutoRoute(
        //   page: DocumentsRoute.page,
        //   path: '/documents',
        //   guards: [AuthGuard()],
        // ),
      ];
}

// Auth Guard to protect routes
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    // Check if user is authenticated
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null && token.isNotEmpty) {
      // User is authenticated, continue navigation
      resolver.next(true);
    } else {
      // User is not authenticated, redirect to login
      resolver.overrideNext();
    }
  }
}
