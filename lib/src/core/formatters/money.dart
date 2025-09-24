// lib/src/core/formatters/money.dart
import 'package:intl/intl.dart';

final _fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
String formatPrice(num value) => _fmt.format(value);
