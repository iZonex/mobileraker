/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../util/logger.dart';

part 'misc_providers.g.dart';

@Riverpod(keepAlive: true)
NetworkInfo networkInfoService(NetworkInfoServiceRef ref) {
  return NetworkInfo();
}

@riverpod
Future<PermissionStatus> permissionStatus(PermissionStatusRef ref, Permission permission) async {
  var status = await permission.status;

  logger.i('Permission $permission is $status');
  return status;
}
