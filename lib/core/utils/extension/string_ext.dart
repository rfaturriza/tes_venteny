import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';

extension StringExt on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isNotGrantedPermissionLocation {
    return this == 'PERMISSION_DENIED' || this == 'PERMISSION_DENIED_NEVER_ASK';
  }

  String shortGuid() {
    // Remove dashes from GUID
    final strippedGUID = replaceAll('-', '');

    // Convert the hex string to a byte array
    final bytes = Uint8List.fromList(List.generate(
      strippedGUID.length ~/ 2,
      (i) => int.parse(strippedGUID.substring(i * 2, i * 2 + 2), radix: 16),
    ));

    // Encode the byte array to Base64 and remove padding
    final base64String = base64UrlEncode(bytes).replaceAll('=', '');
    return base64String.length > 20
        ? base64String.substring(0, 20)
        : base64String;
  }

  DateTime toDateTime() {
    final dateTimeFormat = DateFormat.yMMMMd().add_Hm();

    return dateTimeFormat.parse(this);
  }
}

extension StringExtNullSafety on String? {
  String orEmpty() {
    return this ?? '';
  }
}

const emptyString = '';
