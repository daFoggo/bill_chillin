import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  bool _isProcessing = false;
  bool _ocrProcessing = false;
  MobileScannerController? _controller;
  TextRecognizer? _textRecognizer;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
      _textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan receipt'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Scan with camera is only available on mobile (Android/iOS). '
              'Please run the app on a device or emulator to use QR/OCR features.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan receipt'),
        actions: [
          IconButton(
            tooltip: 'Toggle torch',
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            tooltip: 'Switch camera',
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_isProcessing) return;
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;

                final value = barcodes.first.rawValue;
                if (value == null || value.isEmpty) return;

                _isProcessing = true;

                final scanned = ScannedTransaction(
                  description: value,
                  amount: 0, // OCR/parse amount if có format, để 0 cho user chỉnh
                  date: DateTime.now(),
                );

                context.pushNamed(
                  'review_scanned_transactions',
                  extra: [scanned],
                ).whenComplete(() {
                  _isProcessing = false;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Align the QR/Barcode within the frame to scan. Text OCR can be added later if needed.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _controller?.start(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _controller?.stop(),
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _ocrProcessing ? null : _captureAndOcr,
            icon: const Icon(Icons.document_scanner),
            label: Text(_ocrProcessing ? 'Running OCR...' : 'OCR receipt (photo)'),
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: after detection, we create a temporary transaction with amount = 0. Edit it in Review.',
            style: theme.textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndOcr() async {
    if (kIsWeb) return;
    setState(() => _ocrProcessing = true);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (picked == null) {
        setState(() => _ocrProcessing = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(picked.path);
      final result = await _textRecognizer!.processImage(inputImage);
      final fullText = result.text;

      if (!mounted) return;
      if (fullText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text detected.')),
        );
        setState(() => _ocrProcessing = false);
        return;
      }

      final amount = _parseAmount(fullText) ?? 0.0;
      final date = _parseDate(fullText) ?? DateTime.now();
      final description = _parseDescription(fullText);

      final tx = ScannedTransaction(
        description: description,
        amount: amount,
        date: date,
      );

      await context.pushNamed(
        'review_scanned_transactions',
        extra: [tx],
      );
    } finally {
      if (mounted) setState(() => _ocrProcessing = false);
    }
  }

  double? _parseAmount(String text) {
    // Tìm số có phần thập phân/nhóm, lấy số lớn nhất làm tổng tiền
    final regex = RegExp(r'(\d{1,3}(?:[.,]\d{3})+|\d+[.,]\d{1,2})');
    final matches = regex.allMatches(text);
    double? best;
    for (final m in matches) {
      final raw = m.group(0) ?? '';
      final normalized = raw.replaceAll(RegExp(r'[.,](?=\d{3}\b)'), '');
      final value = double.tryParse(normalized.replaceAll(',', '.'));
      if (value != null) {
        if (best == null || value > best) best = value;
      }
    }
    return best;
  }

  DateTime? _parseDate(String text) {
    final regex = RegExp(r'(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})');
    final match = regex.firstMatch(text);
    if (match == null) return null;
    final raw = match.group(0) ?? '';
    final parts = raw.split(RegExp(r'[\/\-]'));
    if (parts.length != 3) return null;
    int d = int.tryParse(parts[0]) ?? 1;
    int m = int.tryParse(parts[1]) ?? 1;
    int y = int.tryParse(parts[2]) ?? DateTime.now().year;
    if (y < 100) y += 2000;
    return DateTime(y, m, d);
  }

  String _parseDescription(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines.first : 'Scanned receipt';
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer?.close();
    super.dispose();
  }
}



