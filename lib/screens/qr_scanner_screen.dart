import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final String slotNumber;
  final String qrCode;
  
  const QRScannerScreen({
    Key? key, 
    required this.slotNumber,
    required this.qrCode,
  }) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;
      
      _isProcessing = true;
      
      // Verify that the QR code matches the slot number pattern
      final expectedPattern = widget.qrCode;
      if (barcode.rawValue!.startsWith(expectedPattern)) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code. Please scan the correct slot QR code.'),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code for Slot ${widget.slotNumber}'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
            case TorchState.off:
              return const Icon(Icons.flash_off);
            case TorchState.on:
              return const Icon(Icons.flash_on);
            default:
              return const Icon(Icons.flash_off); // Default case
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
            case CameraFacing.front:
              return const Icon(Icons.camera_front);
            case CameraFacing.back:
              return const Icon(Icons.camera_rear);
            default:
              return const Icon(Icons.camera_rear); // Default case
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                CustomPaint(
                  painter: ScannerOverlay(),
                  child: const SizedBox.expand(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Scanning for Slot ${widget.slotNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please scan the QR code displayed at the parking slot',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom overlay painter
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    final Paint paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw the semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
              const Radius.circular(12),
            ),
          ),
      ),
      paint,
    );

    // Draw the scanning frame
    final Paint borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final double cornerSize = 20;

    // Draw corners
    // Top left
    canvas.drawLine(Offset(left, top + cornerSize), Offset(left, top), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), borderPaint);

    // Top right
    canvas.drawLine(Offset(right - cornerSize, top), Offset(right, top), borderPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerSize), borderPaint);

    // Bottom left
    canvas.drawLine(Offset(left, bottom - cornerSize), Offset(left, bottom), borderPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerSize, bottom), borderPaint);

    // Bottom right
    canvas.drawLine(Offset(right - cornerSize, bottom), Offset(right, bottom), borderPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerSize), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}