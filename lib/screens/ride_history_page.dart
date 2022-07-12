import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_sharing_app/models/ride_model.dart';
import 'package:vehicle_sharing_app/notifier/station_bloc.dart';

class RideHistory extends StatefulWidget {
  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Provider.of<StationBloc>(context, listen: false).getUserHistory(),
        builder: (context, AsyncSnapshot<List<RideModel>> snapshot) {
          print(snapshot.data);
          print(snapshot.error);

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                child: Text('No rides yet'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300],
                        width: 1,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[300],
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Ride date: ${snapshot.data[index].date.day}-${snapshot.data[index].date.month}-${snapshot.data[index].date.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'From: ${snapshot.data[index].startingAddress}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'To: ${snapshot.data[index].endingAddress}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Distance: ${snapshot.data[index].distance}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Cost: \$${snapshot.data[index].cost}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );

                  // return ListTile(
                  //   title: Text(snapshot.data[index].startingAddress),
                  //   subtitle: Text(snapshot.data[index].endingAddress),
                  //   trailing: Text(snapshot.data[index].cost),
                  // );
                },
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
