class StationModel {
  String lat;
  String long;
  String address;
  int availableBikes;
  int stationNumber;

  StationModel();

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
      'address': address,
      'availableBikes': availableBikes,
      'stationNumber': stationNumber,
    };
  }

  StationModel.fromMap(Map<String, dynamic> data) {
    lat = data['lat'];
    long = data['long'];
    address = data['address'];
    availableBikes = data['availableBikes'];
    stationNumber = data['stationNumber'];
  }
}
