import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_sharing_app/assistant/assistantMethods.dart';
import 'package:vehicle_sharing_app/models/directionDetails.dart';
import 'package:vehicle_sharing_app/models/station_model.dart';
import 'package:vehicle_sharing_app/models/user.dart';
import 'package:vehicle_sharing_app/notifier/station_bloc.dart';
import 'package:vehicle_sharing_app/screens/profile_page.dart';
import 'package:vehicle_sharing_app/screens/ride_history_page.dart';
import 'package:vehicle_sharing_app/screens/search_dropOff.dart';
import 'package:vehicle_sharing_app/services/authentication_service.dart';
import 'package:vehicle_sharing_app/services/firebase_services.dart';
import 'package:vehicle_sharing_app/widgets/single_station.dart';
import 'package:vehicle_sharing_app/widgets/widgets.dart';

import '../assistant/fireHelper.dart';
import '../globalvariables.dart';
import '../models/nearbyCar.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<StationModel> _stations = [];
  StationModel _selectedStation;

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLinesCoordinates = [];
  Set<Polyline> polylineSet = {};

  double bottomPaddingOfMap = 0;

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  void geolocator = Geolocator();

  double rideDetailContainerHeight = 0;
  double searchDetailContainerHeight = 200;

  bool drawerOpen = true;
  String finalDestination = '';
  String initialLocation = '';

  List nearbyCarId = [];

  void displayRideDetailContainer() async {
    await getPlaceDirection();
    setState(() {
      searchDetailContainerHeight = 0;
      rideDetailContainerHeight = 330;
      bottomPaddingOfMap = 320;
      drawerOpen = false;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchDetailContainerHeight = 280;
      rideDetailContainerHeight = 0;
      bottomPaddingOfMap = 270;

      polylineSet.clear();
      markerSet.clear();
      pLinesCoordinates.clear();
      circleSet.clear();

      locatePosition();
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    // TODO: remove this hardcoded address for MSA location
    LatLng latlngPosition = LatLng(29.9567052, 30.9557575);
    // LatLng latlngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latlngPosition, zoom: 13.5);

    if (newGoogleMapController != null) {
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    String address = await AssistantMethods.searchCoordinateAddress(position, context);
    if (address == '') {
      print('Nulladdress');
    }
    print('Your address::' + address);
    startGeofireListener();
  }

  void startGeofireListener() {
    Geofire.initialize('carsAvailable');
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 20).listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyCar nearbyCar = NearbyCar();
            nearbyCar.key = map['key'];
            nearbyCar.latitude = map['latitude'];
            nearbyCar.longitude = map['longitude'];

            nearbyCarId.add(map['key']);
            FireHelper.nearbyCarList.add(nearbyCar);
            break;

          case Geofire.onKeyExited:
            int index = nearbyCarId.indexWhere((element) => element.key == map['key']);
            nearbyCarId.removeAt(index);
            FireHelper.removeFromList(map['key']);
            break;

          case Geofire.onKeyMoved:
            // Update your key's location

            NearbyCar nearbyCar = NearbyCar();
            nearbyCar.key = map['key'];
            nearbyCar.latitude = map['latitude'];
            nearbyCar.longitude = map['longitude'];

            FireHelper.updateNearByLocation(nearbyCar);
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            print("Firehelper length: ${FireHelper.nearbyCarList.length}");

            break;
        }
      }
      NearbyCar nearbyCar = NearbyCar();
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  AppUser userData;

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void _onMapCreated(GoogleMapController controller, List<StationModel> stations) async {
    _controllerGoogleMap.complete(controller);
    newGoogleMapController = controller;

    final iconByteData = await _getBytesFromAsset(
      'images/bike_marker.png',
      230,
    );

    setState(() {
      bottomPaddingOfMap = 300;

      for (final station in stations) {
        markerSet.add(
          Marker(
            markerId: MarkerId(station.lat.toString() + station.long.toString()),
            position: LatLng(double.parse(station.lat), double.parse(station.long)),
            onTap: () {
              setState(() {
                _selectedStation = station;
              });
            },
            icon: BitmapDescriptor.fromBytes(iconByteData),
          ),
        );
      }
    });

    locatePosition();
  }

  @override
  void initState() {
    locatePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Container(
        width: 255,
        child: Drawer(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ProfilePage();
                    }),
                  );
                },
                child: Container(
                  height: 165,
                  child: DrawerHeader(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          foregroundColor: Colors.blue,
                          backgroundImage: AssetImage(
                            'images/ToyFaces_Colored_BG_47.jpg',
                          ),
                        ),
                        //TODO 1: User photo should be here
                        SizedBox(width: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<AppUser>(
                              future: FirebaseFunctions().getUser(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data.name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return Text('Name');
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Visit Profile',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ), //Drawer Header
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RideHistory();
                    }),
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    'History',
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<AuthenticationService>().signOut(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }),
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    'Sign Out',
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFunctions().getStations(),
        builder: (BuildContext context, AsyncSnapshot<List<StationModel>> snapshot) {
          if (snapshot.hasData) {
            _stations = snapshot.data;
            return Stack(
              children: [
                GoogleMap(
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: false,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  compassEnabled: true,
                  polylines: polylineSet,
                  markers: markerSet,
                  circles: circleSet,
                  onMapCreated: (GoogleMapController controller) {
                    _onMapCreated(controller, _stations);
                  },
                ),
                //Hamburger button for Drawer
                Positioned(
                  top: 45,
                  left: 15,
                  child: GestureDetector(
                    onTap: () {
                      if (drawerOpen) {
                        scaffoldKey.currentState.openDrawer();
                      } else {
                        resetApp();
                      }
                    },
                    child: Container(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          ((drawerOpen) ? Icons.menu : Icons.close),
                          color: Colors.black,
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 6,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (!Provider.of<StationBloc>(context).isStartStationSelected)
                  Positioned(
                    bottom: 120,
                    right: 0,
                    left: 0,
                    child: _selectedStation == null
                        ? SizedBox.shrink()
                        : Opacity(
                            opacity: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: SingleStation(
                                station: _selectedStation,
                                onTap: () {
                                  Provider.of<StationBloc>(context, listen: false).setSelectedStartStation(_selectedStation);
                                  Provider.of<StationBloc>(context, listen: false).isStartStationSelected = true;

                                  setState(() {
                                    _selectedStation = null;
                                  });
                                },
                              ),
                            ),
                          ),
                  ),

                if (Provider.of<StationBloc>(context).isStartStationSelected && !Provider.of<StationBloc>(context).isEndStationSelected)
                  Positioned(
                    bottom: 120,
                    right: 0,
                    left: 0,
                    child: _selectedStation == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleStation(
                              station: _selectedStation,
                              onTap: () {
                                if (Provider.of<StationBloc>(context, listen: false).selectedStartStation.stationNumber != _selectedStation.stationNumber) {
                                  Provider.of<StationBloc>(context, listen: false).setSelectedEndStation(_selectedStation);
                                  Provider.of<StationBloc>(context, listen: false).isEndStationSelected = true;

                                  setState(() {
                                    _selectedStation = null;
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content: Text('You cannot select the same station as start and end station'),
                                        actions: [
                                          FlatButton(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                setState(() {
                                  _selectedStation = null;
                                });
                                getPlaceDirection();
                              },
                            ),
                          ),
                  ),

                // Start station
                if (!Provider.of<StationBloc>(context).isStartStationSelected)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSize(
                      vsync: this,
                      curve: Curves.bounceIn,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              spreadRadius: 0.2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pick Start Station',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Pick the station Closest to you to start your awesome journey.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // End station
                if (Provider.of<StationBloc>(context).isStartStationSelected && !Provider.of<StationBloc>(context).isEndStationSelected)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSize(
                      vsync: this,
                      curve: Curves.bounceIn,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              spreadRadius: 0.2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pick End Station',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Pick the closest station to your destination.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  left: 70,
                  right: 20,
                  top: 42,
                  child: AnimatedSize(
                    vsync: this,
                    curve: Curves.bounceIn,
                    duration: Duration(milliseconds: 500),
                    child: GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return SearchDropOffLocation();
                          }),
                        );

                        if (res != null) {
                          newGoogleMapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: LatLng(res.latitude, res.longitude), zoom: 13.5),
                            ),
                          );
                        }
                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(11),
                          child: Row(
                            children: [
                              Icon(Icons.search),
                              Text(
                                '\t\tSearch Places',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              spreadRadius: 0.2,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (Provider.of<StationBloc>(context).isStartStationSelected && Provider.of<StationBloc>(context).isEndStationSelected)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSize(
                      vsync: this,
                      curve: Curves.bounceIn,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              spreadRadius: 0.2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Station: ${Provider.of<StationBloc>(context).selectedStartStation.stationNumber}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\n${Provider.of<StationBloc>(context).selectedStartStation.address}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'To',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Station: ${Provider.of<StationBloc>(context).selectedEndStation.stationNumber}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\n${Provider.of<StationBloc>(context).selectedEndStation.address}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                          ((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : ''),
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
                                          ((tripDirectionDetails != null) ? '\$ ${AssistantMethods.calculateFares(tripDirectionDetails)}' : ''),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          print('Tapped');

                                          Provider.of<StationBloc>(context, listen: false).setSelectedStartStation(null);
                                          Provider.of<StationBloc>(context, listen: false).setSelectedEndStation(null);
                                          Provider.of<StationBloc>(context, listen: false).isStartStationSelected = false;
                                          Provider.of<StationBloc>(context, listen: false).isEndStationSelected = false;

                                          setState(() {
                                            _selectedStation = null;

                                            polylineSet.clear();
                                            pLinesCoordinates.clear();
                                            circleSet.clear();
                                          });
                                        },
                                        child: CustomButton(
                                          text: 'Reset',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) {
                                              // return CarList(
                                              //   initialLocation: initialLocation,
                                              //   finalDestination: finalDestination,
                                              //   carlist: nearbyCarId,
                                              //   cost: ((tripDirectionDetails != null) ? AssistantMethods.calculateFares(tripDirectionDetails) : 0),
                                              //   pickupDate: "${selectedPickupDate.toLocal()}".split(' ')[0],
                                              //   dropOffDate: "${selectedDropOffDate.toLocal()}".split(' ')[0],
                                              // );
                                            }),
                                          );
                                        },
                                        child: CustomButton(
                                          text: 'Next',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    final iconByteData = await _getBytesFromAsset(
      'images/bike_marker.png',
      230,
    );

    var initialPos = Provider.of<StationBloc>(context, listen: false).selectedStartStation;
    var finalPos = Provider.of<StationBloc>(context, listen: false).selectedEndStation;

    var pickUpLatLng = LatLng(double.parse(initialPos.lat), double.parse(initialPos.long));
    var dropOffLatLng = LatLng(double.parse(finalPos.lat), double.parse(finalPos.long));

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Please Wait....'),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
      finalDestination = finalPos.address;
      initialLocation = initialPos.address;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();

    List<PointLatLng> decodedPolylinePointResult = polylinePoints.decodePolyline(details.encodedPoints);

    pLinesCoordinates.clear();

    if (decodedPolylinePointResult.isNotEmpty) {
      decodedPolylinePointResult.forEach((PointLatLng pointLatLng) {
        pLinesCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(
      () {
        Polyline polyline = Polyline(
          color: Colors.green,
          polylineId: PolylineId('PolyLineID'),
          jointType: JointType.round,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: pLinesCoordinates,
          geodesic: true,
        );

        polylineSet.add(polyline);

        LatLngBounds latLngBounds;

        if (pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude) {
          latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
        } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
          latLngBounds = LatLngBounds(
            southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
            northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          );
        } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
          latLngBounds = LatLngBounds(
            southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
            northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          );
        } else {
          latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
        }

        newGoogleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(latLngBounds, 100),
        );

        Marker pickUpLocMarker = Marker(
          icon: BitmapDescriptor.fromBytes(iconByteData),
          infoWindow: InfoWindow(title: initialPos.address, snippet: 'PickUp'),
          position: pickUpLatLng,
          markerId: MarkerId('pickUpId'),
        );

        Marker dropOffLocMarker = Marker(
          icon: BitmapDescriptor.fromBytes(iconByteData),
          infoWindow: InfoWindow(title: finalPos.address, snippet: 'DropOff'),
          position: dropOffLatLng,
          markerId: MarkerId('dropOffId'),
        );

        setState(() {
          markerSet.add(pickUpLocMarker);
          markerSet.add(dropOffLocMarker);
        });

        Circle pickUpLocCircle = Circle(
          fillColor: Colors.blueAccent,
          center: pickUpLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.blueAccent,
          circleId: CircleId('pickUpId'),
        );

        Circle dropOffLocCircle = Circle(
          fillColor: Colors.deepPurple,
          center: dropOffLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.deepPurple,
          circleId: CircleId('dropOffId'),
        );

        setState(() {
          circleSet.add(pickUpLocCircle);
          circleSet.add(dropOffLocCircle);
        });
      },
    );
  }
}
