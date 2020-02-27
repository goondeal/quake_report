import 'package:flutter/material.dart';


class UsedColors{
  static Color mag1 =  Colors.cyanAccent;
  static Color mag2 =  Colors.cyan;
  static Color mag3 =  Colors.blue;
  static Color mag4 =  Colors.amberAccent;
  static Color mag5 =  Colors.orange;
  static Color mag6 =  Colors.deepOrangeAccent;
  static Color mag7 =  Colors.deepOrange;
  static Color mag8 =  Colors.redAccent;
  static Color mag9 =  Colors.red;

   static Color choose(double mag){
    switch(mag.round()){
      case 1:
        return mag1;
      case 2:
        return mag2;
      case 3:
        return mag3;
      case 4:
        return mag4;
      case 5:
        return mag5;
      case 6:
        return mag6;
      case 7:
        return mag7;
      case 8:
        return mag8;
      default:
        return mag9;
    }
  }
}