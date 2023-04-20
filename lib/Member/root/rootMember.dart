import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project001/Member/account.dart';
import 'package:project001/User/home.dart';
import 'package:project001/User/menu.dart';
import 'package:project001/User/post.dart';
import 'package:project001/User/search.dart';
import 'package:project001/utility/my_constant.dart';

class RootMember extends StatefulWidget {
  const RootMember({Key? key}) : super(key: key);

  @override
  _RootMemberState createState() => _RootMemberState();
}

class _RootMemberState extends State<RootMember> {
  double sizeIcon = 22;
  double sizeNavbar = 40;
  int currentTap = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentScreen),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: sizeNavbar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildHome(),
              buildSearch(),
              buildPost(),
              buildMemu(),
              buildAccount(),
            ],
          ),
        ),
      ),
    );
  }

  MaterialButton buildAccount() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = Account();
          currentTap = 4;
        });
      },
      child: FaIcon(
        FontAwesomeIcons.user,
        size: sizeIcon,
        color: currentTap == 4 ? MyConstant.dark : Colors.grey,
      ),
    );
  }

  MaterialButton buildPost() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = Post();
          currentTap = 2;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.plus,
            size: sizeIcon,
            color: currentTap == 2 ? MyConstant.dark : Colors.grey,
          ),
        ],
      ),
    );
  }

  MaterialButton buildMemu() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = Menu();
          currentTap = 3;
        });
      },
      child: FaIcon(
        FontAwesomeIcons.microsoft,
        size: sizeIcon,
        color: currentTap == 3 ? MyConstant.dark : Colors.grey,
      ),
    );
  }

  MaterialButton buildSearch() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = Search();
          currentTap = 1;
        });
      },
      child: FaIcon(
        FontAwesomeIcons.search,
        size: sizeIcon,
        color: currentTap == 1 ? MyConstant.dark : Colors.grey,
      ),
    );
  }

  MaterialButton buildHome() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = Home();
          currentTap = 0;
        });
      },
      child: FaIcon(
        FontAwesomeIcons.home,
        size: sizeIcon,
        color: currentTap == 0 ? MyConstant.dark : Colors.grey,
      ),
    );
  }
}
