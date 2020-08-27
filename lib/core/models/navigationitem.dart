import 'package:flutter/material.dart';

class NavigationItem{
  String title;
  Widget navPage;
  IconData icon;
  int notifications;
  NavigationItem({@required this.title, @required this.navPage, @required this.icon,  this.notifications = 0});  
}