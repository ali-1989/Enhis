import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';

import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_sizes.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double center = AppSizes.getScreenHeight(context) / 2;

    return SafeArea(
      child: Material(
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
                /*image: DecorationImage(
                  image: AssetImage(AppImages.logoSplash),
                  fit: BoxFit.fill,
                )*/
              color: Colors.white
            ),
            child: Column(
              children: [
                SizedBox(
                  height: center,
                  child: SlideInUp(
                    delay: const Duration(seconds: 2),
                    duration: const Duration(milliseconds: 2000),
                    from: center-70,
                    child: FadeIn(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 2000),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: 70,
                          width: 100,
                          child: Image.asset(AppImages.appIcon,
                            width: 90,
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                FadeIn(
                    delay: const Duration(milliseconds: 0),
                    duration: const Duration(milliseconds: 4000),
                    child: Column(
                      children: [
                        const Text('از امنیت بالا لذت ببرید').bold().fsR(3).color(Colors.pink),
                        const Text('enjoy High security').fsR(2),
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
