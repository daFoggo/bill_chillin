import 'dart:convert';
import 'package:bill_chillin/core/error/exceptions.dart';
import 'package:bill_chillin/features/scan/data/models/scanned_transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class ScanRemoteDataSource {
  Future<List<ScannedTransactionModel>> scanReceipt(Uint8List imageBytes);
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final http.Client client;

  ScanRemoteDataSourceImpl({required this.client});

  static const int _maxRetries = 1;

  // Fallback API keys
  static final List<String> _fallbackApiKeys = [
    dotenv.env['FALLBACK_API_KEY_1'] ?? '',
    dotenv.env['FALLBACK_API_KEY_2'] ?? '',
    dotenv.env['FALLBACK_API_KEY_3'] ?? '',
  ].where((key) => key.isNotEmpty).toList();

  @override
  Future<List<ScannedTransactionModel>> scanReceipt(
    Uint8List imageBytes,
  ) async {
    String? primaryApiKey = dotenv.env['GEMINI_API_KEY'];
    if (primaryApiKey == null || primaryApiKey.isEmpty) {
      if (_fallbackApiKeys.isNotEmpty) {
        primaryApiKey = _fallbackApiKeys.first;
        debugPrint('Using fallback API key (no key in .env)');
      } else {
        throw ServerException('No API keys available');
      }
    }

    final List<String> apiKeysToTry = [primaryApiKey, ..._fallbackApiKeys];
    final uniqueKeys = apiKeysToTry.toSet().toList();

    Exception? lastException;
    http.Response? successfulResponse;

    const prompt = '''
You are a receipt parsing assistant.
Given an image of a receipt, extract all purchase line items and return ONLY a valid JSON object with this exact structure:
{
  "transactions": [
    {
      "note": "short item name or description on the receipt line",
      "categoryName": "Food | Drinks | Transport | Groceries | Entertainment | Shopping | Bills | Other",
      "amount": 123.45,
      "currency": "VND",
      "date": "YYYY-MM-DD"
    }
  ]
}
- "note": short name/description of the line item.
- "categoryName": high-level category in English.
- "amount": numeric value.
- "currency": Detect currency from receipt (e.g. VND, USD). Default to VND if unclear.
- "date": purchase date in ISO format YYYY-MM-DD. If not visible, use today's date.
Return ONLY the JSON, without any additional text, explanation, markdown, or code fences.''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
    };

    for (int keyIndex = 0; keyIndex < uniqueKeys.length; keyIndex++) {
      final currentApiKey = uniqueKeys[keyIndex];
      final isPrimaryKey = keyIndex == 0;

      if (!isPrimaryKey) {
        debugPrint(
          'Trying fallback API key $keyIndex/${uniqueKeys.length - 1}',
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$currentApiKey',
      );

      bool keySucceeded = false;
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          if (attempt > 0) {
            final delaySeconds = (attempt * 2);
            debugPrint(
              'Retrying API call after ${delaySeconds}s (attempt ${attempt + 1}/$_maxRetries)',
            );
            await Future.delayed(Duration(seconds: delaySeconds));
          }

          final response = await client
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(requestBody),
              )
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  throw Exception('Request timeout after 30 seconds');
                },
              );

          if (response.statusCode == 200) {
            successfulResponse = response;
            keySucceeded = true;
            debugPrint(
              'API call succeeded with ${isPrimaryKey ? "primary" : "fallback"} key',
            );
            break;
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            debugPrint(
              'Invalid API key (${response.statusCode}), trying next key...',
            );
            lastException = ServerException(
              'Invalid API key (${response.statusCode})',
            );
            break;
          } else if (response.statusCode == 429) {
            if (isPrimaryKey && keyIndex < uniqueKeys.length - 1) {
              debugPrint('Rate limited on primary key, trying fallback...');
              break;
            } else {
              lastException = ServerException(
                'Rate limit exceeded (${response.statusCode})',
              );
              if (attempt < _maxRetries - 1) {
                final delaySeconds = (attempt + 1) * 10;
                await Future.delayed(Duration(seconds: delaySeconds));
                continue;
              }
            }
          } else if (response.statusCode == 503) {
            lastException = ServerException(
              'Service temporarily unavailable (${response.statusCode})',
            );
            if (attempt < _maxRetries - 1) {
              continue;
            }
          } else {
            lastException = ServerException(
              'AI request failed: ${response.statusCode} ${response.body}',
            );
            if (isPrimaryKey && keyIndex < uniqueKeys.length - 1) {
              break;
            } else {
              break;
            }
          }
        } catch (e) {
          debugPrint('API call failed: $e');
          lastException = e is Exception ? e : Exception(e.toString());
          if (attempt < _maxRetries - 1) {
            continue;
          }
        }
      }

      if (keySucceeded) {
        break;
      }
    }

    if (successfulResponse == null) {
      throw lastException ??
          ServerException(
            'Failed to get response from API after trying all keys',
          );
    }

    final decoded = jsonDecode(successfulResponse.body);
    final parts = decoded['candidates']?[0]?['content']?['parts'] as List?;
    final combinedText =
        parts?.map((p) => (p['text'] as String?) ?? '').join('\n').trim() ?? '';

    if (combinedText.isEmpty) {
      return [];
    }

    dynamic jsonResult;
    try {
      final start = combinedText.indexOf('{');
      final end = combinedText.lastIndexOf('}');
      final jsonSlice = (start != -1 && end != -1 && end > start)
          ? combinedText.substring(start, end + 1)
          : combinedText;
      jsonResult = jsonDecode(jsonSlice);
    } catch (_) {
      throw ServerException('Failed to parse AI response as JSON');
    }

    final List<dynamic> items =
        (jsonResult['transactions'] as List?) ?? const [];
    return items.map((item) => ScannedTransactionModel.fromJson(item)).toList();
  }
}
