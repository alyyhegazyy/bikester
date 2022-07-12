class RideModel {
  DateTime date;
  String distance;
  String cost;
  String startingAddress;
  String endingAddress;

  RideModel();

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'distance': distance,
      'cost': cost,
      'startingAddress': startingAddress,
      'endingAddress': endingAddress,
    };
  }

  RideModel.fromMap(Map<String, dynamic> data) {
    date = data['date'] != null ? DateTime.fromMillisecondsSinceEpoch(data['date']) : null;
    distance = data['distance'];
    cost = data['cost'];
    startingAddress = data['startingAddress'];
    endingAddress = data['endingAddress'];
  }
}
