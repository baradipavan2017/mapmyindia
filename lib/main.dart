import 'package:flutter/material.dart';
import 'package:flutter_app/maps/search_screen.dart';

import 'maps/maps_screen.dart';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      routes: {
        '/': (context)=> MapScreen(),
        '/search': (context) => Search(),
      },

    );
  }
}
