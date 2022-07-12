import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_sharing_app/models/ride_model.dart';
import 'package:vehicle_sharing_app/notifier/station_bloc.dart';
import 'package:vehicle_sharing_app/screens/ride_history_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class PaymentPage extends StatefulWidget {
  final RideModel rideModel;
  PaymentPage({@required this.rideModel});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    openCheckOut();
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void handlerPaymentSuccess() {
    Toast.show('Payment Successful', context);
  }

  void handlerErrorFailure() {
    Toast.show('Payment Failed', context);
  }

  void handlerExternalWallet() {}

  void saveUserHistory() async {
    try {
      await FirebaseFirestore.instance.collection('history').add(<String, dynamic>{
        'cost': widget.rideModel.cost,
        'date': DateTime.now().millisecondsSinceEpoch,
        'distance': widget.rideModel.distance,
        'startingAddress': widget.rideModel.startingAddress,
        'endingAddress': widget.rideModel.endingAddress,
        'createdOn': DateTime.now().millisecondsSinceEpoch,
        'modifiedOn': DateTime.now().millisecondsSinceEpoch,
        'userId': FirebaseAuth.instance.currentUser.uid,
      });

      Provider.of<StationBloc>(context, listen: false).setSelectedStartStation(null);
      Provider.of<StationBloc>(context, listen: false).setSelectedEndStation(null);
      Provider.of<StationBloc>(context, listen: false).isStartStationSelected = false;
      Provider.of<StationBloc>(context, listen: false).isEndStationSelected = false;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  void openCheckOut() async {
    var options = {
      'key': "rzp_test_l8yCRSz3UfiXKB",
      'amount': '${double.parse(widget.rideModel.cost) * 100}',
      'description': 'Your ride',
      "prefill": {
        "contact": '9876543210',
        "email": FirebaseAuth.instance.currentUser.email,
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    saveUserHistory();
    return RideHistory();
  }
}
