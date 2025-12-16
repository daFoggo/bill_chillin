import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan receipt'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera preview will be displayed here',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: Integrate camera / OCR and pass extracted data as extra
                context.pushNamed('review_scanned_transactions');
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start scan'),
            ),
          ],
        ),
      ),
    );
  }
}



