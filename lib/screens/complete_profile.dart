import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_sharing_app/models/user.dart';
import 'package:vehicle_sharing_app/screens/home_page.dart';
import 'package:vehicle_sharing_app/services/firebase_services.dart';
import 'package:vehicle_sharing_app/services/validation_services.dart';
import 'package:vehicle_sharing_app/widgets/loading_wrapper.dart';
import 'package:vehicle_sharing_app/widgets/widgets.dart';

class CompleteProfile extends StatefulWidget {
  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _bloodController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  AppUser user = AppUser();

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  void initAppUser() {
    user.name = _nameController.text;
    user.age = _ageController.text;
    user.bloodGroup = _bloodController.text;
    user.contact = _contactController.text;
    user.emailID = FirebaseAuth.instance.currentUser.email;
    user.hasCompleteProfile = true;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Builder(
        builder: (context) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomBackButton(
                      pageHeader: 'Complete your profile',
                      isNeedToShowBackButton: false,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InputFormField(
                      fieldName: 'Name',
                      obscure: false,
                      validator: ValidationService().nameValidator,
                      controller: _nameController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Age',
                      obscure: false,
                      validator: ValidationService().ageValidator,
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Blood Type',
                      obscure: false,
                      validator: ValidationService().bloodValidator,
                      controller: _bloodController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Contact Number',
                      obscure: false,
                      validator: ValidationService().contactValidator,
                      controller: _contactController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 0.05 * deviceSize.height,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          ///Tell the user that process has started
                          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing')));

                          ///Initialize User after successful validation of fields
                          initAppUser();

                          ///Make the call to upload user data
                          String isComplete = await firebaseFunctions.uploadUserData(user.toMap());

                          ///Check if it was uploaded successfully or else show the error
                          if (isComplete == 'true') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return HomePage();
                                },
                              ),
                            );
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text(isComplete)));
                          }
                        }
                      },
                      child: CustomButton(
                        text: 'Save',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
