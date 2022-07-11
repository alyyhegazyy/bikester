import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_sharing_app/screens/complete_profile.dart';
import 'package:vehicle_sharing_app/screens/login_page.dart';
import 'package:vehicle_sharing_app/services/authentication_service.dart';
import 'package:vehicle_sharing_app/widgets/loading_wrapper.dart';

import '../widgets/widgets.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _submitting = false;

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  var emailIdController = TextEditingController();

  var passwordController = TextEditingController();

  var confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      isSubmitting: _submitting,
      child: Scaffold(
        key: scaffoldKey,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Text(
                  'Bikester',
                  style: TextStyle(
                    fontSize: 53,
                    letterSpacing: 2.3,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe',
                  ),
                ),
                SizedBox(height: 40),
                InputTextField(
                  controller: emailIdController,
                  label: 'Email-Id',
                  obscure: false,
                  icon: Icon(Icons.email_outlined),
                ),
                InputTextField(
                  controller: passwordController,
                  label: 'Password',
                  obscure: true,
                  icon: Icon(Icons.lock),
                ),
                InputTextField(
                  controller: confirmPassController,
                  label: 'Confirm Password',
                  obscure: true,
                  icon: Icon(Icons.lock),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    var connectivityResult = await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) {
                      showSnackBar('No Internet connectivity');
                      return;
                    }

                    if (!emailIdController.text.contains('@')) {
                      showSnackBar('Please provide a valid email address');
                      return;
                    }

                    if (passwordController.text.length < 6) {
                      showSnackBar('Please provide a password of length more than 6');
                      return;
                    }

                    if (passwordController.text != confirmPassController.text) {
                      showSnackBar('Passwords do not match');
                      return;
                    }

                    setState(() {
                      _submitting = true;
                    });

                    var res = await context.read<AuthenticationService>().signUp(
                          email: emailIdController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                    if (res == "Signed up") {
                      setState(() {
                        _submitting = false;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CompleteProfile();
                          },
                        ),
                      );
                    } else {
                      setState(() {
                        _submitting = false;
                      });
                      showSnackBar(res);
                    }
                  },
                  child: CustomButton(
                    text: 'Sign Up',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return LoginPage();
                      }),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a registered user?\t',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'Login here',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
