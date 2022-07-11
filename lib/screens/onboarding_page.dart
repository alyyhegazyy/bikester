import 'dart:async';

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:vehicle_sharing_app/constants/app_theme.dart';
import 'package:vehicle_sharing_app/widgets/widgets.dart';

import '../main.dart';

class OnboradingPage extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboradingPage({Key key}) : super(key: key);

  @override
  State<OnboradingPage> createState() => _OnboradingPageState();
}

class _OnboradingPageState extends State<OnboradingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {});
    });
  }

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AuthenticationWrapper.routeName, (_) => false);
  }

  Widget _buildImage(String assetName) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Image.asset('images/onboarding/$assetName.png', width: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currPageIndex = (introKey.currentState?.controller?.page ?? 0) + 1;
    final lastPageIndex = introKey.currentState?.getPagesLength() ?? 0;

    introKey.currentState?.controller?.addListener(() {
      setState(() {});
    });

    const bodyStyle = TextStyle(fontSize: 14);
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyTextStyle: bodyStyle,
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top: 60),
      contentMargin: EdgeInsets.only(top: 100),
      bodyPadding: EdgeInsets.symmetric(horizontal: 20),
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: 'Take a trip today',
          body: 'Bikester helps you to find the best bike for your trip.',
          image: _buildImage('img1'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Get a chance to ride your favorite bike',
          body: 'With Bikester you can choose your favorite bike and take a trip today!',
          image: _buildImage('img2'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Riding bike is cool but safety looks cooler',
          body: 'Bikester will give you the safest and fastest way to ride your bike.',
          image: _buildImage('img3'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      dotsFlex: 0,
      nextFlex: 0,
      isTopSafeArea: true,
      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 30, right: 10),
          child: TextButton(
            onPressed: () => _onIntroEnd(context),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff969696),
              ),
            ),
          ),
        ),
      ),

      showNextButton: false,
      globalFooter: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 10),
              child: currPageIndex == lastPageIndex
                  ? FooterButton(
                      onPress: () {
                        _onIntroEnd(context);
                      },
                      text: 'Get Started')
                  : FooterButton(
                      onPress: () {
                        introKey.currentState?.next();
                      },
                      text: 'Next'),
            ),
          ),
        ],
      ),
      // doneColor: kPrimaryColor,
      showDoneButton: false,
      dotsDecorator: DotsDecorator(
        size: const Size(8, 8),
        color: const Color(0xFFBDBDBD),
        activeColor: AppTheme.primaryColor,
        activeSize: const Size(18, 8),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    );
  }
}

class FooterButton extends StatelessWidget {
  final VoidCallback onPress;
  final String text;

  const FooterButton({
    Key key,
    @required this.onPress,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: CustomButton(
        text: text,
      ),
    );
  }
}
