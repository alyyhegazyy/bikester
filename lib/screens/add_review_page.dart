import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_sharing_app/notifier/station_bloc.dart';
import 'package:vehicle_sharing_app/widgets/widgets.dart';

import 'home_page.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({Key key}) : super(key: key);

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  double routeSafetyRating = 3;
  double routeBikeFriendlyRating = 3;
  double bikeRating = 3;
  double overallExperienceRating = 3;

  String feedback = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Your Ride'),
        centerTitle: false,
        actions: [
          TextButton(
            child: Text('SKIP', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Provider.of<StationBloc>(context, listen: false).setSelectedStartStation(null);
              Provider.of<StationBloc>(context, listen: false).setSelectedEndStation(null);
              Provider.of<StationBloc>(context, listen: false).isStartStationSelected = false;
              Provider.of<StationBloc>(context, listen: false).isEndStationSelected = false;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(colors: [
              Colors.blue.shade400,
              Colors.blue.shade900,
            ]).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              'WE HOPE YOU ENJOYED YOUR RIDE WITH BIKESTER!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Help us make your coming\nrides even better!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6f7478), fontSize: 14),
          ),
          SizedBox(height: 20),
          RatingTile(
            title: 'ROUTE SAFETY',
            onUpdateRating: (rating) {
              setState(() {
                routeSafetyRating = rating;
              });
            },
          ),
          RatingTile(
            title: 'ROUTE BIKE FRIENDLY',
            onUpdateRating: (rating) {
              setState(() {
                routeBikeFriendlyRating = rating;
              });
            },
          ),
          RatingTile(
            title: 'BIKE',
            onUpdateRating: (rating) {
              setState(() {
                bikeRating = rating;
              });
            },
          ),
          RatingTile(
            title: 'OVERALL EXPERIENCE',
            onUpdateRating: (rating) {
              setState(() {
                overallExperienceRating = rating;
              });
            },
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Feedback',
              alignLabelWithHint: true,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            minLines: 3,
            maxLines: 100,
            onChanged: (value) {
              setState(() {
                feedback = value;
              });
            },
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseFirestore.instance.collection('review').add(<String, dynamic>{
                  'date': DateTime.now().millisecondsSinceEpoch,
                  'routeSafetyRating': routeSafetyRating,
                  'routeBikeFriendlyRating': routeBikeFriendlyRating,
                  'bikeRating': bikeRating,
                  'overallExperienceRating': overallExperienceRating,
                  'feedback': feedback,
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
            },
            child: CustomButton(
              text: 'Submit',
            ),
          ),
        ],
      ),
    );
  }
}

class RatingTile extends StatelessWidget {
  final String title;
  final Function onUpdateRating;

  const RatingTile({
    Key key,
    @required this.title,
    @required this.onUpdateRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade200,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: RatingBar.builder(
        initialRating: 3,
        direction: Axis.horizontal,
        minRating: 1,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 20,
        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: onUpdateRating,
      ),
    );
  }
}
