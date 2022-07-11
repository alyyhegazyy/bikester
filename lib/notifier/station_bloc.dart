import 'package:flutter/foundation.dart';
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
}
