import 'dart:convert';

import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final ImagePicker _picker = ImagePicker();
  bool _processing = false;
  DateTime? _lastApiCallTime;
  static const Duration _minApiCallInterval = Duration(
    seconds: 2,
  ); // Tối thiểu 2 giây giữa các lần gọi
  static const int _maxRetries = 3;

  // Fallback API keys nếu key trong .env thất bại
  static final List<String> _fallbackApiKeys = [
    dotenv.env['FALLBACK_API_KEY_1']!,
    dotenv.env['FALLBACK_API_KEY_2']!,
    dotenv.env['FALLBACK_API_KEY_3']!,
    dotenv.env['FALLBACK_API_KEY_4']!,
    dotenv.env['FALLBACK_API_KEY_5']!,
    dotenv.env['FALLBACK_API_KEY_6']!,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan receipt')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Scanning receipts with the camera is only available on mobile (Android/iOS).\n'
              'Please run the app on a device or emulator to use AI receipt scanning.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan receipt')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Take a photo of your receipt and let AI extract transactions for review.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _processing ? null : _onCapturePressed,
                icon: const Icon(Icons.camera_alt),
                label: Text(_processing ? 'Analyzing...' : 'Capture receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCapturePressed() async {
    if (kIsWeb) return;

    final now = DateTime.now();
    if (_lastApiCallTime != null) {
      final timeSinceLastCall = now.difference(_lastApiCallTime!);
      if (timeSinceLastCall < _minApiCallInterval) {
        final remainingSeconds =
            (_minApiCallInterval.inSeconds - timeSinceLastCall.inSeconds);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait ${remainingSeconds}s before scanning again',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    setState(() => _processing = true);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _processing = false);
        return;
      }

      final bytes = await picked.readAsBytes();

      _lastApiCallTime = DateTime.now();

      final transactions = await _analyzeReceiptWithAi(bytes);

      if (!mounted) return;

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No transactions detected from the image'),
          ),
        );
        return;
      }

      await context.pushNamed(
        'review_scanned_transactions',
        extra: transactions,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to analyze receipt: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<List<ScannedTransaction>> _analyzeReceiptWithAi(
    Uint8List imageBytes,
  ) async {
    // Lấy API key từ .env hoặc dùng fallback
    String? primaryApiKey = dotenv.env['GEMINI_API_KEY'];
    if (primaryApiKey == null || primaryApiKey.isEmpty) {
      // Nếu không có key trong .env, dùng fallback đầu tiên
      primaryApiKey = _fallbackApiKeys.first;
      debugPrint('Using fallback API key (no key in .env)');
    }

    // Tạo danh sách keys để thử (primary key + fallback keys)
    final List<String> apiKeysToTry = [primaryApiKey, ..._fallbackApiKeys];

    // Loại bỏ duplicate nếu primary key trùng với một trong fallback keys
    final uniqueKeys = apiKeysToTry.toSet().toList();

    Exception? lastException;
    http.Response? successfulResponse;

    const prompt = '''
You are a receipt parsing assistant.
Given an image of a receipt, extract all purchase line items and return ONLY a valid JSON object with this exact structure:
{
  "transactions": [
    {
      "description": "short item name on the receipt line",
      "category": "Food | Drinks | Transport | Groceries | Entertainment | Shopping | Bills | Other",
      "amount": 123.45,
      "date": "YYYY-MM-DD"
    }
  ]
}
- "description": short name of the line item.
- "category": high-level category in English.
- "amount": numeric value using dot as decimal separator.
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

    // Thử với từng API key (primary + fallbacks)
    for (int keyIndex = 0; keyIndex < uniqueKeys.length; keyIndex++) {
      final currentApiKey = uniqueKeys[keyIndex];
      final isPrimaryKey = keyIndex == 0;

      if (!isPrimaryKey) {
        debugPrint(
          'Trying fallback API key $keyIndex/${uniqueKeys.length - 1}',
        );
        // Đợi một chút trước khi thử key tiếp theo
        await Future.delayed(const Duration(seconds: 1));
      }

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$currentApiKey',
      );

      // Retry với exponential backoff cho mỗi key
      bool keySucceeded = false;
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          // Nếu không phải lần thử đầu tiên, đợi một chút trước khi retry
          if (attempt > 0) {
            final delaySeconds = (attempt * 2); // 2s, 4s, 6s...
            debugPrint(
              'Retrying API call after ${delaySeconds}s (attempt ${attempt + 1}/$_maxRetries)',
            );
            await Future.delayed(Duration(seconds: delaySeconds));
          }

          final response = await http
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(requestBody),
              )
              .timeout(
                const Duration(seconds: 30), // Timeout sau 30 giây
                onTimeout: () {
                  throw Exception('Request timeout after 30 seconds');
                },
              );

          // Xử lý các status code khác nhau
          if (response.statusCode == 200) {
            // Thành công, lưu response và break khỏi cả 2 loops
            successfulResponse = response;
            lastException = null;
            keySucceeded = true;
            debugPrint(
              'API call succeeded with ${isPrimaryKey ? "primary" : "fallback"} key',
            );
            break;
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            // Invalid API key - thử key tiếp theo ngay lập tức
            debugPrint(
              'Invalid API key (${response.statusCode}), trying next key...',
            );
            lastException = Exception(
              'Invalid API key (${response.statusCode})',
            );
            break; // Break khỏi retry loop, thử key tiếp theo
          } else if (response.statusCode == 429) {
            // Rate limit - nếu là primary key, thử fallback. Nếu đã là fallback, retry với delay
            if (isPrimaryKey && keyIndex < uniqueKeys.length - 1) {
              debugPrint('Rate limited on primary key, trying fallback...');
              break; // Break khỏi retry loop, thử fallback key
            } else {
              // Đã là fallback key, retry với delay
              lastException = Exception(
                'Rate limit exceeded (${response.statusCode})',
              );
              if (attempt < _maxRetries - 1) {
                final delaySeconds = (attempt + 1) * 10;
                debugPrint(
                  'Rate limited. Waiting ${delaySeconds}s before retry...',
                );
                await Future.delayed(Duration(seconds: delaySeconds));
                continue;
              }
            }
          } else if (response.statusCode == 503) {
            // Service unavailable - retry với backoff
            lastException = Exception(
              'Service temporarily unavailable (${response.statusCode})',
            );
            if (attempt < _maxRetries - 1) {
              continue; // Sẽ retry với delay đã tính ở trên
            }
          } else {
            // Lỗi khác - không retry, thử key tiếp theo
            lastException = Exception(
              'AI request failed: ${response.statusCode} ${response.body}',
            );
            if (isPrimaryKey && keyIndex < uniqueKeys.length - 1) {
              debugPrint(
                'Error ${response.statusCode} on primary key, trying fallback...',
              );
              break; // Break khỏi retry loop, thử fallback key
            } else {
              break; // Break khỏi retry loop
            }
          }
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          if (attempt < _maxRetries - 1) {
            continue; // Retry
          }
        }
      }

      // Nếu key này thành công, break khỏi key loop
      if (keySucceeded) {
        break;
      }
    }

    // Nếu vẫn lỗi sau tất cả keys và retries
    if (lastException != null || successfulResponse == null) {
      throw lastException ??
          Exception('Failed to get response from API after trying all keys');
    }

    // Parse response từ successful response
    final decoded = jsonDecode(successfulResponse.body);
    final parts = decoded['candidates']?[0]?['content']?['parts'] as List?;
    final combinedText =
        parts?.map((p) => (p['text'] as String?) ?? '').join('\n').trim() ?? '';
    if (combinedText.isEmpty) {
      return [];
    }

    dynamic jsonResult;
    try {
      // Một số khi model có thể trả thêm text thừa, nên cố gắng cắt lấy đoạn JSON thuần.
      final start = combinedText.indexOf('{');
      final end = combinedText.lastIndexOf('}');
      final jsonSlice = (start != -1 && end != -1 && end > start)
          ? combinedText.substring(start, end + 1)
          : combinedText;
      jsonResult = jsonDecode(jsonSlice);
    } catch (_) {
      throw Exception('Failed to parse AI response as JSON');
    }

    final List<dynamic> items =
        (jsonResult['transactions'] as List?) ?? const [];
    return items.map<ScannedTransaction>((item) {
      final desc = item['description']?.toString() ?? 'Item';
      final category = item['category']?.toString() ?? '';
      double amount = 0.0;
      final amountRaw = item['amount'];
      if (amountRaw is num) {
        amount = amountRaw.toDouble();
      } else if (amountRaw is String) {
        amount = double.parse(amountRaw);
      }
      DateTime date;
      final dateStr = item['date']?.toString();
      try {
        date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
      } catch (_) {
        date = DateTime.now();
      }

      return ScannedTransaction(
        description: desc,
        category: category,
        amount: amount,
        date: date,
      );
    }).toList();
  }
}
