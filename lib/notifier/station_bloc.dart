import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vehicle_sharing_app/models/review_model.dart';
import 'package:vehicle_sharing_app/models/ride_model.dart';
import 'package:vehicle_sharing_app/models/station_model.dart';

class StationBloc extends ChangeNotifier {
  StationModel _selectedStartStation;
  StationModel _selectedEndStation;

  bool isStartStationSelected = false;
  bool isEndStationSelected = false;

  StationModel get selectedStartStation => _selectedStartStation;
  StationModel get selectedEndStation => _selectedEndStation;

  void setSelectedStartStation(StationModel station) {
    _selectedStartStation = station;
    isStartStationSelected = true;
    notifyListeners();
  }

  void setSelectedEndStation(StationModel station) {
    _selectedEndStation = station;
    isEndStationSelected = true;
    notifyListeners();
  }

  Future<List<RideModel>> getUserHistory() async {
    List<RideModel> history = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('history').where('userId', isEqualTo: FirebaseAuth.instance.currentUser.uid).get();

    for (var doc in snapshot.docs) {
      history.add(RideModel.fromMap(doc.data()));
    }

    return history;
  }

  Future<List<ReviewModel>> getReviews() async {
    List<ReviewModel> reviews = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('review').where('userId', isEqualTo: FirebaseAuth.instance.currentUser.uid).get();

    for (var doc in snapshot.docs) {
      reviews.add(ReviewModel.fromMap(doc.data()));
    }

    return reviews;
  }
}
