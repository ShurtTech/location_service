// core/services/battery_optimization_service.dart

import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class BatteryOptimizationService {
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }
  
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (Platform.isAndroid) {
      return await Permission.ignoreBatteryOptimizations.isGranted;
    }
    return true;
  }
}
