import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_sharing_app/assistant/request.dart';
import 'package:vehicle_sharing_app/configMaps.dart';
import 'package:vehicle_sharing_app/dataHandler/appdata.dart';
import 'package:vehicle_sharing_app/models/address.dart';
import 'package:vehicle_sharing_app/models/directionDetails.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = '';

    String add1, add2, add3, add4;
    // TODO: remove this hardcoded address for MSA location
    // String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$geocodingApi';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=29.9567052,30.9557575&key=$geocodingApi';

    var response = await RequestAssistant.getRequest(url);

    if (response != 'failed') {
      // placeAddress = response["results"][0]['formatted_address']; //FULL ADDRESS WILL BE SHOWN BY THIS
      add1 = response["results"][0]['address_components'][1]['long_name']; //neighborhood
      add2 = response["results"][0]['address_components'][2]['long_name']; //sublocality
      add3 = response["results"][0]['address_components'][3]['long_name']; //administrative_area_level_2
      add4 = response["results"][0]['address_components'][4]['long_name']; //country

      placeAddress = '$add1, $add2, $add3, $add4';

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocation(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$geocodingApi";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == 'failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res['routes'][0]['overview_polyline']['points'];
    directionDetails.distanceText = res['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = res['routes'][0]['legs'][0]['distance']['value'];
    directionDetails.durationText = res['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = res['routes'][0]['legs'][0]['duration']['value'];

    return directionDetails;
  }

  static String calculateFares(DirectionDetails directionDetails) {
    double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 3;
    return distanceTraveledFare.toStringAsFixed(2);
  }
}
