// ignore_for_file: depend_on_referenced_packages

import 'package:intl/intl.dart';

extension IntExt on int? {
  String formatPrice() {
    if (this == null) return '';
    // Create a NumberFormat instance for currency formatting
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Format the price as a currency string
    return currencyFormat.format(this!);
  }

  String afterDiscount(double? discountPercentage) {
    if (this == null) return '';
    if (discountPercentage == null) return '';
    final priceAfterDiscount = this! - (this! * (discountPercentage / 100));
    return priceAfterDiscount.formatPrice();
  }
}

extension DoubleExt on double? {
  String formatPrice() {
    if (this == null) return '';
    // Create a NumberFormat instance for currency formatting
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Format the price as a currency string
    return currencyFormat.format(this!);
  }

  String afterDiscount(double? discountPercentage) {
    if (this == null) return '';
    if (discountPercentage == null) return '';
    final priceAfterDiscount = this! - (this! * discountPercentage);
    return priceAfterDiscount.formatPrice();
  }
}

extension DateTimeExt on DateTime {
  String formatDate() {
    // Create a DateFormat instance for date formatting
    final dateFormat = DateFormat('dd MMM yyyy');

    // Format the date as a string
    return dateFormat.format(this);
  }

  String formatTime() {
    // Create a DateFormat instance for time formatting
    final timeFormat = DateFormat('hh:mm a');

    // Format the time as a string
    return timeFormat.format(this);
  }

  String formatDateTime() {
    final dateTimeFormat = DateFormat.yMMMMd().add_Hm().format(this);

    return dateTimeFormat;
  }
}
