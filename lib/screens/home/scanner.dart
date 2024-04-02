import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wallet/screens/transfer/sendtokens.dart';
import 'package:wallet/splshscreen.dart';

class ScannerView extends StatefulWidget {
  static String routeName = "/qrscan";

  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  // late Size size;
  final GlobalKey _qrKey = GlobalKey(debugLabel: "QR");
  TextEditingController Codecontroller = TextEditingController();
  QRViewController? _controller;
  bool isFlashOff = true;
  Barcode? result;
  bool isBuild = false;
  double kDesignHeight = 852.0;

  TextEditingController amountcontroller = TextEditingController();

  TextEditingController commentcontroller = TextEditingController();

  bool isturned = false;

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    if (!isBuild && _controller != null) {
      _controller?.pauseCamera();
      _controller?.resumeCamera();
      setState(() {
        isBuild = true;
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        title: const Text(
          'Scan QR Code',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox(
            height: myHeight,
            width: myWidth,
            child: _buildQrView(context),
          ),
        ],
      ),
    );
  }

  double getProportionateScreenHeight(double inputHeight) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // 812 is the layout height that designer use
    return (inputHeight / kDesignHeight) * screenHeight;
  }

  void onPermissionSet(
      BuildContext context, QRViewController ctrl, bool permisson) {
    if (!permisson) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No Permision')));
    }
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = getProportionateScreenHeight(200);
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRviewCreated,
      onPermissionSet: (ctrl, p) => onPermissionSet(context, ctrl, p),
      overlay: QrScannerOverlayShape(
        cutOutSize: scanArea,
        borderWidth: getProportionateScreenHeight(8),
        borderColor: Colors.red,
        borderLength: getProportionateScreenHeight(15),
        borderRadius: 4,
      ),
    );
  }

  void _onQRviewCreated(QRViewController qrController) async {
    setState(() {
      _controller = qrController;
    });
    _controller?.scannedDataStream.listen((event) async {
      setState(() {
        result = event;
      });
      if (result?.code != null) {
        if (isturned == false) {
          isturned = true;
          walleTRefrence
              .child(result?.code.toString() as String)
              .once()
              .then((DatabaseEvent databaseEvent) {
            if (databaseEvent.snapshot.value != null) {
              setState(() {
                _controller?.pauseCamera();
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SendTokens(
                            balance: result?.code.toString() as String,
                          )));
            }
          });
        }
      }
    });
  }

  Widget _showResult(String sehercode) {
    return Center(
        child: FutureBuilder<dynamic>(
      future: showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                title: Text(
                  'Scan Result $sehercode',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [],
                  ),
                ),
              ),
              onWillPop: () async => false,
            );
          }),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        throw UnimplementedError;
      },
    ));
  }
}
