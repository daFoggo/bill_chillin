import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final ImagePicker _picker = ImagePicker();
  DateTime? _lastApiCallTime;
  static const Duration _minApiCallInterval = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScanBloc>(),
      child: BlocListener<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanSuccess) {
            context.pushNamed(
              'review_scanned_transactions',
              extra: state.transactions,
            );
          } else if (state is ScanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to analyze receipt: ${state.message}'),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: _ScanReceiptView(
          picker: _picker,
          onCapture: (context) => _onCapturePressed(context),
          isProcessing: (context) {
            final state = context.watch<ScanBloc>().state;
            return state is ScanLoading;
          },
        ),
      ),
    );
  }

  Future<void> _onCapturePressed(BuildContext context) async {
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

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      _lastApiCallTime = DateTime.now();

      if (context.mounted) {
        context.read<ScanBloc>().add(ScanReceiptCaptured(bytes));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: \$e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class _ScanReceiptView extends StatelessWidget {
  final ImagePicker picker;
  final Function(BuildContext) onCapture;
  final bool Function(BuildContext) isProcessing;

  const _ScanReceiptView({
    required this.picker,
    required this.onCapture,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final processing = isProcessing(context);

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
                onPressed: processing ? null : () => onCapture(context),
                icon: const Icon(Icons.camera_alt),
                label: Text(processing ? 'Analyzing...' : 'Capture receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
