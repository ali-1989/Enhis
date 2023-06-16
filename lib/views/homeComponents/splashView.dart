import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';

import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSizes.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double center = AppSizes.getScreenHeight(context) / 2 - 50;

    return SafeArea(
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
              /*image: DecorationImage(
                image: AssetImage(AppImages.logoSplash),
                fit: BoxFit.fill,
              )*/
            color: Colors.white
          ),
          child: SlideInUp(
            delay: const Duration(seconds: 2),
            duration: const Duration(milliseconds: 1500),
            from: center,
            child: FadeIn(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 2000),
              child: UnconstrainedBox(
                alignment: Alignment.topCenter,
                child: Image.asset(AppImages.appIcon,
                  width: 90,
                  height: 70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
