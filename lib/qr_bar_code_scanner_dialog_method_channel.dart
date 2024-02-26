import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'qr_bar_code_scanner_dialog_platform_interface.dart';
import 'responsive.dart';

/// An implementation of [QrBarCodeScannerDialogPlatform] that uses method channels.
class MethodChannelQrBarCodeScannerDialog
    extends QrBarCodeScannerDialogPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('qr_bar_code_scanner_dialog');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void scanBarOrQrCode(
      {BuildContext? context, required Function(String? code) onScanSuccess}) {
    /// context is required to show alert in non-web platforms
    assert(context != null);

    final Responsive responsive = Responsive.of(context!);

    showDialog(
        context: context!,
        builder: (context) => SafeArea(
              child: Container(
                  alignment: Alignment.center,
                  color: const Color(0xFF12605B),
                  child: Stack(children: <Widget>[
                    ScannerWidget(onScanSuccess: (code) {
                      if (code != null) {
                        Navigator.pop(context);
                        onScanSuccess(code);
                      }
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(responsive.fdp(20)),
                            child: Image.asset(
                              "lib/assets/remove_round.png",
                              width: responsive.fdp(40),
                              height: responsive.fdp(40),
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: Image.asset(
                        "lib/assets/scan_frame.png",
                        width: responsive.fdp(300),
                        height: responsive.fdp(300),
                        fit: BoxFit.contain,
                      ),
                    )
                  ])),
            ));
  }
}

class ScannerWidget extends StatefulWidget {
  final void Function(String? code) onScanSuccess;

  const ScannerWidget({super.key, required this.onScanSuccess});

  @override
  createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  QRViewController? controller;
  GlobalKey qrKey = GlobalKey(debugLabel: 'scanner');

  bool isScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    /// dispose the controller
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildQrView(context);
  }

  Widget _buildQrView(BuildContext context) {
    double smallestDimension = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    smallestDimension = min(smallestDimension, 550);

    return QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          _onQRViewCreated(controller);
        });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((Barcode scanData) async {
      if (!isScanned) {
        isScanned = true;
        widget.onScanSuccess(scanData.code);
      }
    });
  }
}
