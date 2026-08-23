import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class OcrExtractionResult {
  OcrExtractionResult({
    required this.rawText,
    required this.title,
    required this.category,
    this.issueDate,
    this.expiryDate,
    this.documentNumber,
    this.amount,
    this.merchant,
    this.confidenceScore = 0.0,
    this.detectedTokens = const [],
  });

  final String rawText;
  final String title;
  final String category;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? documentNumber;
  final String? amount;
  final String? merchant;
  final double confidenceScore;
  final List<String> detectedTokens;
}

class OcrEngineService {
  /// On-Device ML Kit OCR Text Extraction (Works 100% offline with zero latency on mobile)
  static Future<String> recognizeTextOnDevice(Uint8List imageBytes) async {
    try {
      final tempDir = await Directory.systemTemp.createTemp('lifevault_ocr_');
      final tempFile = File('${tempDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      try {
        if (await tempFile.exists()) await tempFile.delete();
        if (await tempDir.exists()) await tempDir.delete();
      } catch (_) {}

      return recognizedText.text.trim();
    } catch (e) {
      debugPrint('On-Device ML Kit OCR note: $e');
      return '';
    }
  }

  /// Extracts structured fields from raw OCR text using regex and heuristics
  static OcrExtractionResult extractFields(String text) {
    if (text.trim().isEmpty) {
      return OcrExtractionResult(
        rawText: text,
        title: 'New Document',
        category: 'Other',
        confidenceScore: 0.0,
      );
    }

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final lowerText = text.toLowerCase();

    // 1. Detect Category & Title
    String category = 'Other';
    String title = lines.isNotEmpty ? lines.first : 'Scanned Document';

    if (lowerText.contains('passport') ||
        lowerText.contains('republic') ||
        lowerText.contains('nationality') ||
        lowerText.contains('identity card') ||
        lowerText.contains('id card') ||
        lowerText.contains('driver license') ||
        lowerText.contains('driving licence')) {
      category = 'Identity';
      if (lowerText.contains('passport')) title = 'Passport';
      if (lowerText.contains('driver')) title = 'Driver License';
      if (lowerText.contains('identity card') || lowerText.contains('id card')) {
        title = 'National ID Card';
      }
    } else if (lowerText.contains('insurance') ||
        lowerText.contains('policy') ||
        lowerText.contains('coverage') ||
        lowerText.contains('premium') ||
        lowerText.contains('underwritten')) {
      category = 'Insurance';
      if (lowerText.contains('auto') || lowerText.contains('car')) {
        title = 'Vehicle Insurance Policy';
      } else if (lowerText.contains('health') || lowerText.contains('medical')) {
        title = 'Health Insurance Policy';
      } else {
        title = 'Insurance Policy Document';
      }
    } else if (lowerText.contains('medical') ||
        lowerText.contains('hospital') ||
        lowerText.contains('prescription') ||
        lowerText.contains('doctor') ||
        lowerText.contains('diagnosis') ||
        lowerText.contains('clinic')) {
      category = 'Medical';
      title = 'Medical Record';
    } else if (lowerText.contains('university') ||
        lowerText.contains('college') ||
        lowerText.contains('degree') ||
        lowerText.contains('diploma') ||
        lowerText.contains('transcript') ||
        lowerText.contains('certificate')) {
      category = 'Education';
      title = 'Academic Certificate';
    } else if (lowerText.contains('vehicle') ||
        lowerText.contains('registration') ||
        lowerText.contains('vin') ||
        lowerText.contains('chassis') ||
        lowerText.contains('automobile')) {
      category = 'Vehicle';
      title = 'Vehicle Registration';
    } else if (lowerText.contains('warranty') ||
        lowerText.contains('guarantee') ||
        lowerText.contains('serial no') ||
        lowerText.contains('appliance')) {
      category = 'Warranties';
      title = 'Warranty Certificate';
    } else if (lowerText.contains('receipt') ||
        lowerText.contains('invoice') ||
        lowerText.contains('subtotal') ||
        lowerText.contains('total') ||
        lowerText.contains('tax') ||
        lowerText.contains('cashier')) {
      category = 'Receipts';
      title = 'Purchase Receipt';
    } else if (lowerText.contains('utility') ||
        lowerText.contains('electricity') ||
        lowerText.contains('water bill') ||
        lowerText.contains('lease') ||
        lowerText.contains('rent')) {
      category = 'Bills';
      title = 'Bill Statement';
    }

    // 2. Extract Dates (Expiry & Issue Dates)
    final extractedDates = _findDates(text);
    DateTime? expiryDate;
    DateTime? issueDate;

    // Search for expiry date context keywords
    final expiryPattern = RegExp(
      r'(?:expiry|expires|exp\b|valid\s+thru|valid\s+until|due\s+date|renewal)[:\s]*([0-9]{1,4}[/\-.][0-9]{1,2}[/\-.][0-9]{1,4}|[A-Za-z]+\s+[0-9]{1,2},?\s+[0-9]{4})',
      caseSensitive: false,
    );
    final expiryMatch = expiryPattern.firstMatch(text);
    if (expiryMatch != null && expiryMatch.groupCount >= 1) {
      expiryDate = _parseDateString(expiryMatch.group(1)!);
    }

    // Search for issue date context keywords
    final issuePattern = RegExp(
      r'(?:issue|issued|date\s+of\s+issue|effective|start\s+date)[:\s]*([0-9]{1,4}[/\-.][0-9]{1,2}[/\-.][0-9]{1,4}|[A-Za-z]+\s+[0-9]{1,2},?\s+[0-9]{4})',
      caseSensitive: false,
    );
    final issueMatch = issuePattern.firstMatch(text);
    if (issueMatch != null && issueMatch.groupCount >= 1) {
      issueDate = _parseDateString(issueMatch.group(1)!);
    }

    // Heuristics if keyword match was not found
    if (expiryDate == null && extractedDates.isNotEmpty) {
      // Future dates or latest date tends to be expiry
      final now = DateTime.now();
      final futureDates = extractedDates.where((d) => d.isAfter(now)).toList();
      if (futureDates.isNotEmpty) {
        futureDates.sort();
        expiryDate = futureDates.first;
      }
    }

    if (issueDate == null && extractedDates.isNotEmpty) {
      final now = DateTime.now();
      final pastDates = extractedDates.where((d) => d.isBefore(now)).toList();
      if (pastDates.isNotEmpty) {
        pastDates.sort((a, b) => b.compareTo(a));
        issueDate = pastDates.first;
      }
    }

    // 3. Extract Document Number / Policy Number / Passport No
    String? docNumber;
    final docNumPattern = RegExp(
      r'(?:passport\s+no|doc\s+no|number|no\.|id\s+no|policy\s+no|license\s+no|reg\s+no|vin)[:\s]*([A-Z0-9\-_]{5,20})',
      caseSensitive: false,
    );
    final docNumMatch = docNumPattern.firstMatch(text);
    if (docNumMatch != null && docNumMatch.groupCount >= 1) {
      docNumber = docNumMatch.group(1)?.trim();
    }

    // 4. Extract Amount
    String? amount;
    final amountPattern = RegExp(
      r'(?:total|amount|due|paid|balance)[:\s]*([$€£₹]?\s*[0-9]+(?:[.,][0-9]{2})?)',
      caseSensitive: false,
    );
    final amountMatch = amountPattern.firstMatch(text);
    if (amountMatch != null && amountMatch.groupCount >= 1) {
      amount = amountMatch.group(1)?.trim();
    } else {
      // Look for standalone currency values
      final currencyPattern = RegExp(r'[$€£₹]\s*[0-9]+(?:[.,][0-9]{2})?');
      final cMatch = currencyPattern.firstMatch(text);
      if (cMatch != null) {
        amount = cMatch.group(0)?.trim();
      }
    }

    // 5. Extract Merchant (if first line has store name)
    String? merchant;
    if (category == 'Receipts' || category == 'Bills') {
      merchant = lines.isNotEmpty ? lines.first : null;
    }

    // 6. Token list and confidence calculation
    final detectedTokens = <String>[];
    if (category != 'Other') detectedTokens.add('Category: $category');
    if (expiryDate != null) {
      detectedTokens.add('Expiry: ${DateFormat('yyyy-MM-dd').format(expiryDate)}');
    }
    if (issueDate != null) {
      detectedTokens.add('Issued: ${DateFormat('yyyy-MM-dd').format(issueDate)}');
    }
    if (docNumber != null) detectedTokens.add('ID: $docNumber');
    if (amount != null) detectedTokens.add('Amount: $amount');

    double confidence = 0.5;
    if (detectedTokens.isNotEmpty) {
      confidence = (0.5 + (detectedTokens.length * 0.12)).clamp(0.0, 0.98);
    }

    return OcrExtractionResult(
      rawText: text,
      title: title,
      category: category,
      issueDate: issueDate,
      expiryDate: expiryDate,
      documentNumber: docNumber,
      amount: amount,
      merchant: merchant,
      confidenceScore: confidence,
      detectedTokens: detectedTokens,
    );
  }

  static List<DateTime> _findDates(String text) {
    final results = <DateTime>[];

    // Pattern 1: DD/MM/YYYY or MM/DD/YYYY or YYYY-MM-DD
    final datePattern = RegExp(
      r'\b([0-9]{1,4})[/\-.]([0-9]{1,2})[/\-.]([0-9]{1,4})\b',
    );
    for (final match in datePattern.allMatches(text)) {
      final parsed = _parseDateString(match.group(0)!);
      if (parsed != null) results.add(parsed);
    }

    // Pattern 2: Month DD, YYYY (e.g. October 14, 2026 or 14 Oct 2026)
    final wordDatePattern = RegExp(
      r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+[0-9]{1,2},?\s+[0-9]{4}\b|\b[0-9]{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+[0-9]{4}\b',
      caseSensitive: false,
    );
    for (final match in wordDatePattern.allMatches(text)) {
      final parsed = _parseDateString(match.group(0)!);
      if (parsed != null) results.add(parsed);
    }

    return results;
  }

  static DateTime? _parseDateString(String input) {
    final clean = input.trim();
    final formats = [
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
      'yyyy/MM/dd',
      'MMMM dd, yyyy',
      'MMM dd, yyyy',
      'dd MMMM yyyy',
      'dd MMM yyyy',
      'MMMM dd yyyy',
      'MMM dd yyyy',
    ];

    for (final fmt in formats) {
      try {
        final parsed = DateFormat(fmt).parseLoose(clean);
        // Sanity check year bounds
        if (parsed.year >= 1950 && parsed.year <= 2100) {
          return parsed;
        }
      } catch (_) {}
    }
    return null;
  }
}
