import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_sharing_app/screens/home_page.dart';
import 'package:vehicle_sharing_app/screens/signup_page.dart';
import 'package:vehicle_sharing_app/services/authentication_service.dart';
import 'package:vehicle_sharing_app/widgets/loading_wrapper.dart';
import 'package:vehicle_sharing_app/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      isSubmitting: _submitting,
      child: Scaffold(
        key: scaffoldKey,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Bikester',
                    style: TextStyle(
                      fontSize: 53,
                      letterSpacing: 2.3,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe',
                      // color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
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
                        SizedBox(
                          height: 30,
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

                            setState(() {
                              _submitting = true;
                            });

                            var res = await context.read<AuthenticationService>().signIn(
                                  email: emailIdController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                            if (res == "Signed in") {
                              setState(() {
                                _submitting = false;
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return HomePage();
                              }));
                            } else {
                              setState(() {
                                _submitting = false;
                              });
                              showSnackBar(res);
                            }
                          },
                          child: CustomButton(
                            text: 'Login',
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
                                return SignUpPage();
                              }),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have any account?\t",
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                'SignUp here',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
