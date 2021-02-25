import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

typedef Widget PageBuilder();

class PageRoutes {
  // HOW TO USE
  //   //Show SharedAxis Page - Provides 3 axis, vt, hz and scale
  // // Navigator.push(context, PageRoutes.sharedAxis(()=>MyPage(), SharedAxisTransitionType.scaled));

  // //Show FadeThrough Page
  // // Navigator.push(context, PageRoutes.fadeThrough(()=>MyPage()));

  // //Show FadeScale dialog
  // // showModal(
  // //     context: context,
  // //     configuration: FadeScaleTransitionConfiguration(),
  // //     builder: (BuildContext context) => MyDialog());

  static Route<T> fadeThrough<T>(PageBuilder page, [double duration = 0.5]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child);
      },
    );
  }

  static Route<T> fadeScale<T>(PageBuilder page, [double duration = 0.5]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
    );
  }

  static Route<T> sharedAxis<T>(PageBuilder page,
      [SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
      double duration = 0.5]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
        );
      },
    );
  }

  static Route<T> fromBottom<T>(PageBuilder page,
      [SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
      double duration = 0.5]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, -1.0);
        var end = Offset.zero;
        var curve = Curves.decelerate;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
