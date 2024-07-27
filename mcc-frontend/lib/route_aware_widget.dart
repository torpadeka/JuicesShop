import 'package:JuicesShop/home_page.dart';
import 'package:JuicesShop/login_page.dart';
import 'package:JuicesShop/register_page.dart';
import 'package:flutter/material.dart';

class RouteAwareWidget extends StatefulWidget {
  final Widget child;

  const RouteAwareWidget({Key? key, required this.child}) : super(key: key);

  @override
  RouteAwareWidgetState createState() => RouteAwareWidgetState();
}

class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  @override
  void didPopNext() {
    super.didPopNext();
    // User returned to this screen, re-check the token validity
    // Example:
    if (widget.child is LoginPageState) {
      (widget.child as LoginPageState).checkTokenValidity();
    }

    if (widget.child is RegisterPageState) {
      (widget.child as RegisterPageState).checkTokenValidity();
    }

    if (widget.child is HomePageState) {
      (widget.child as HomePageState).checkTokenValidity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
