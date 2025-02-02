/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:common/data/enums/webcam_service_type.dart';
import 'package:common/data/model/hive/machine.dart';
import 'package:common/data/model/moonraker_db/webcam_info.dart';
import 'package:common/network/jrpc_client_provider.dart';
import 'package:common/network/json_rpc_client.dart';
import 'package:common/util/misc.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobileraker/ui/components/mjpeg.dart';

class WebcamMjpeg extends ConsumerWidget {
  const WebcamMjpeg({
    Key? key,
    required this.webcamInfo,
    required this.machine,
    this.imageBuilder,
    this.stackChild = const [],
    this.showFps = false,
  }) : super(key: key);

  final WebcamInfo webcamInfo;

  final Machine machine;

  final StreamConnectedBuilder? imageBuilder;

  final List<Widget> stackChild;

  final bool showFps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var clientType = ref.watch(jrpcClientTypeProvider(machine.uuid));
    var octoEverywhere = machine.octoEverywhere;
    var machineUri = machine.wsUri;

    var camStreamUrl = webcamInfo.streamUrl;
    var camSnapshotUrl = webcamInfo.snapshotUrl;

    var configBuilder = MjpegConfigBuilder()
      ..mode =
          (webcamInfo.service == WebcamServiceType.mjpegStreamerAdaptive) ? MjpegMode.adaptiveStream : MjpegMode.stream
      ..targetFps = webcamInfo.targetFps
      ..rotation = webcamInfo.rotation
      ..transformation = webcamInfo.transformMatrix;

    switch (clientType) {
      case ClientType.octo:
        configBuilder.timeout = const Duration(seconds: 30);
        var baseUri = octoEverywhere!.uri
            .replace(userInfo: '${octoEverywhere.authBasicHttpUser}:${octoEverywhere.authBasicHttpPassword}');
        configBuilder
          ..streamUri = buildRemoteWebCamUri(baseUri, machineUri, camStreamUrl)
          ..snapshotUri = buildRemoteWebCamUri(baseUri, machineUri, camSnapshotUrl);
        break;
      case ClientType.manual:
        var remoteInterface = machine.remoteInterface!;
        configBuilder
          ..timeout = remoteInterface.timeoutDuration
          ..httpHeader = {
            if (machine.apiKey?.isNotEmpty == true) 'X-Api-Key': machine.apiKey!,
            ...remoteInterface.httpHeaders
          }
          ..streamUri = buildRemoteWebCamUri(remoteInterface.remoteUri, machineUri, camStreamUrl)
          ..snapshotUri = buildRemoteWebCamUri(remoteInterface.remoteUri, machineUri, camSnapshotUrl);
      case ClientType.local:
      default:
        configBuilder
          ..streamUri = buildWebCamUri(machineUri, camStreamUrl)
          ..snapshotUri = buildWebCamUri(machineUri, camSnapshotUrl);
        break;
    }

    return Mjpeg(
      key: ValueKey(webcamInfo.uuid + machine.uuid),
      imageBuilder: imageBuilder,
      config: configBuilder.build(),
      showFps: showFps,
      stackChild: [
        ...stackChild,
      ],
    );
  }
}
