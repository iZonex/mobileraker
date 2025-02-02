/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:freezed_annotation/freezed_annotation.dart';

import 'config_led.dart';

part 'config_neopixel.freezed.dart';
part 'config_neopixel.g.dart';

String unpackColorOrder(List<dynamic> e) => e.isEmpty ? '' : e.cast<String>().first.toUpperCase();

@freezed
class ConfigNeopixel extends ConfigLed with _$ConfigNeopixel {
  const ConfigNeopixel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ConfigNeopixel({
    required String name,
    @JsonKey(required: true) required String pin,
    required int chainCount,
    @JsonKey(fromJson: unpackColorOrder) @Default('RGB') String colorOrder,
    @Default(0) double initialRed,
    @Default(0) double initialGreen,
    @Default(0) double initialBlue,
    @Default(0) double initialWhite,
  }) = _ConfigNeopixel;

  factory ConfigNeopixel.fromJson(String name, Map<String, dynamic> json) =>
      _$ConfigNeopixelFromJson({...json, 'name': name});

  @override
  bool get isAddressable => true;

  @override
  bool get hasWhite => colorOrder.contains('W');
}
