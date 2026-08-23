class CurrencyConfig {
  const CurrencyConfig({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateFromUsd,
    required this.label,
  });

  final String code;
  final String name;
  final String symbol;
  final double rateFromUsd; // Multiplier relative to 1 USD base
  final String label; // e.g. "USD ($)"
}

class CurrencyHelper {
  static const List<CurrencyConfig> currencies = [
    CurrencyConfig(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      rateFromUsd: 1.0,
      label: 'USD (\$)',
    ),
    CurrencyConfig(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      rateFromUsd: 0.92,
      label: 'EUR (€)',
    ),
    CurrencyConfig(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      rateFromUsd: 0.79,
      label: 'GBP (£)',
    ),
    CurrencyConfig(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      rateFromUsd: 86.50,
      label: 'INR (₹)',
    ),
    CurrencyConfig(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      rateFromUsd: 155.0,
      label: 'JPY (¥)',
    ),
    CurrencyConfig(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      rateFromUsd: 1.38,
      label: 'CAD (C\$)',
    ),
    CurrencyConfig(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      rateFromUsd: 1.54,
      label: 'AUD (A\$)',
    ),
  ];

  /// Finds the matching currency config from a currency label string (e.g. "INR (₹)")
  static CurrencyConfig getConfig(String? currencyLabel) {
    if (currencyLabel == null || currencyLabel.isEmpty) {
      return currencies.first;
    }
    for (final c in currencies) {
      if (c.label.toLowerCase() == currencyLabel.toLowerCase() ||
          c.code.toLowerCase() == currencyLabel.toLowerCase() ||
          currencyLabel.contains(c.symbol)) {
        return c;
      }
    }
    return currencies.first;
  }

  /// Extracts the symbol from a currency label
  static String getSymbol(String? currencyLabel) {
    return getConfig(currencyLabel).symbol;
  }

  /// Gets the conversion rate from USD for a given currency
  static double getRate(String? currencyLabel) {
    return getConfig(currencyLabel).rateFromUsd;
  }

  /// Converts a USD base amount into the target currency
  static double convertFromUsd(double usdAmount, String? targetCurrencyLabel) {
    final rate = getRate(targetCurrencyLabel);
    return usdAmount * rate;
  }

  /// Converts an amount in given currency back to USD base
  static double convertToUsd(double amountInCurrency, String? currencyLabel) {
    final rate = getRate(currencyLabel);
    if (rate <= 0) return amountInCurrency;
    return amountInCurrency / rate;
  }

  /// Formats a USD amount into the target currency representation with proper symbol
  static String format(
    double usdAmount,
    String? currencyLabel, {
    int decimals = 0,
    bool showCode = false,
  }) {
    final config = getConfig(currencyLabel);
    final converted = usdAmount * config.rateFromUsd;

    String numberStr;
    if (decimals == 0) {
      // Use comma grouping for integers
      numberStr = converted.round().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else {
      final parts = converted.toStringAsFixed(decimals).split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      numberStr = '$intPart.${parts[1]}';
    }

    if (showCode) {
      return '${config.symbol}$numberStr ${config.code}';
    }
    return '${config.symbol}$numberStr';
  }

  /// Extracts a numerical amount from a string (e.g. "$1,450.00" -> 1450.00)
  static double parseAmount(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Re-formats a stored document amount string to display in user's current currency
  static String formatDocumentAmount(String? rawAmount, String? userCurrency) {
    if (rawAmount == null || rawAmount.trim().isEmpty) return '';
    final parsedUsd = parseAmount(rawAmount);
    if (parsedUsd == 0.0) return rawAmount;
    return format(parsedUsd, userCurrency, decimals: 2);
  }
}
