import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermission {
  String permissionStatus = "notGranted";
  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      permissionStatus = "Granted";
      debugPrint("Permission already granted");
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        debugPrint("Permission already granted");
        permissionStatus = "Granted";
        return true;
      }
    }
    debugPrint(
        "Permission status: $permissionStatus the permission has not been granted. why");
    permissionStatus = "notGranted";
    return false;
  }
}
