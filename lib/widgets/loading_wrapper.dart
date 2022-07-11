import 'package:flutter/material.dart';

class LoadingWrapper extends StatelessWidget {
  final bool isSubmitting;
  final Widget child;

  const LoadingWrapper({
    Key key,
    @required this.isSubmitting,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          child,
          if (isSubmitting)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(.85),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
