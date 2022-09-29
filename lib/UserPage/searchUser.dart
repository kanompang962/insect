import 'package:flutter/material.dart';
import 'package:project001/utility/size_helper.dart';


class SearchUser extends StatefulWidget {
  const SearchUser({Key? key}) : super(key: key);

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  @override
  Widget build(BuildContext context) {
    double w = displayWidth(context);
    double h = displayHeight(context) -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    return Scaffold(
        appBar:buidAppbar(),
    );
  }
  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Search Page',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'iannnnn-DUCK',
          fontWeight: FontWeight.w900,
          fontSize: 25,
        ),
      ),
    );
  }
}
