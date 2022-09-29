import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:project001/ExpertPage/accountDevelop.dart';
import 'package:project001/MemberPage/homeMember.dart';
import 'package:project001/MemberPage/postMember.dart';
import 'package:project001/MemberPage/searchMember.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/nabar_key.dart';

class RootExpert extends StatefulWidget {
  const RootExpert({Key? key}) : super(key: key);

  @override
  _RootExpertState createState() => _RootExpertState();
}

class _RootExpertState extends State<RootExpert> {
  int selectedIndex = 4;
  final screen = [
    HomeMember(),
    null,
    PostMember(),
    SearchMember(),
    AccountExpert(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[selectedIndex],
      bottomNavigationBar: buidFooter(),
    );
  }

  AppBar buidheader() {
    return AppBar(
      elevation: 0,
      title: Text(
        MyConstant.appNameEN,
      ),
      backgroundColor: Colors.white,
    );
  }

  CurvedNavigationBar buidFooter() {
    return CurvedNavigationBar(
      //color: MyConstant.primary,
      buttonBackgroundColor: MyConstant.primary,
      backgroundColor: Colors.white,
      key: NavbarKey.getKey(),
      items: [
        Icon(
          Icons.home,
          size: 30,
        ),
        Icon(
          Icons.menu,
          size: 30,
        ),
        Icon(
          Icons.photo_camera,
          size: 50,
        ),
        Icon(
          Icons.search,
          size: 30,
        ),
        Icon(
          Icons.account_circle,
          size: 30,
        ),
      ],
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      
      animationCurve: Curves.easeInSine,
      animationDuration: Duration(milliseconds: 300),
    );
  }
}
