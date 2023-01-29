import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vehicle_sharing_app/screens/payement_gateway_page.dart';
import 'package:vehicle_sharing_app/widgets/widgets.dart';
import 'package:vehicle_sharing_app/models/ride_model.dart';

class LockQrCodeScreen extends StatefulWidget {
  final RideModel rideModel;

  const LockQrCodeScreen({Key key, @required this.rideModel}) : super(key: key);

  @override
  _LockQrCodeScreenState createState() => _LockQrCodeScreenState();
}

class _LockQrCodeScreenState extends State<LockQrCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lock Your Bike'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 1,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Please take a picture of the locked bike.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'images/lock.jpg',
                    height: 100,
                  ),
                  Spacer(),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Ride - \t',
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${widget.rideModel.distance}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Cost of Ride - \t',
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '\$${widget.rideModel.cost}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            rideModel: widget.rideModel,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButton(
                        text: 'Pay Now',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
