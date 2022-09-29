import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project001/MemberPage/accountMember.dart';
import 'package:project001/MemberPage/homeMember.dart';
import 'package:project001/MemberPage/insectLiteMember.dart';
import 'package:project001/MemberPage/menuMember.dart';
import 'package:project001/MemberPage/postMember.dart';
import 'package:project001/MemberPage/searchMember.dart';
import 'package:project001/utility/my_constant.dart';

class RootMember extends StatefulWidget {
  const RootMember({Key? key}) : super(key: key);

  @override
  _RootMemberState createState() => _RootMemberState();
}

class _RootMemberState extends State<RootMember> {
  int currentTap = 0;
  List<Widget> screens = [
    HomeMember(),
    MenuMember(),
    InsectLiteMember(),
    SearchMember(),
    AccountMember()
  ];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = HomeMember();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentScreen),
      /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: MyConstant.primary,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PostMember()));
        },
      ),*/
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             
                  buildHome(),
                  buildSearch(),
                  buildInsectLite(),
                  buildMemu(),
                  buildAccount(),
              
            ],
          ),
        ),
      ),
    );
  }

  MaterialButton buildInsectLite() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = InsectLiteMember();
          currentTap = 2;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.bug,
            color: currentTap == 2 ? MyConstant.dark : Colors.grey,
          ),
        ],
      ),
    );
  }

  MaterialButton buildAccount() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = AccountMember();
          currentTap = 4;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.user,
            color: currentTap == 4 ? MyConstant.dark : Colors.grey,
          ),
          /*Text(
            'Account',
            style: GoogleFonts.prompt(
                color: currentTap == 3 ? MyConstant.dark : Colors.grey),
          ),*/
        ],
      ),
    );
  }

  MaterialButton buildMemu() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = MenuMember();
          currentTap = 3;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.navicon,
            color: currentTap == 3 ? MyConstant.dark : Colors.grey,
          ),
          /*Text(
            'Menu',
            style: GoogleFonts.prompt(
                color: currentTap == 2 ? MyConstant.dark : Colors.grey),
          ),*/
        ],
      ),
    );
  }

  MaterialButton buildSearch() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = SearchMember();
          currentTap = 1;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.search,
            color: currentTap == 1 ? MyConstant.dark : Colors.grey,
          ),
          /*Text(
            'Feed',
            style: GoogleFonts.prompt(
                color: currentTap == 1 ? MyConstant.dark : Colors.grey),
          ),*/
        ],
      ),
    );
  }

  MaterialButton buildHome() {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = HomeMember();
          currentTap = 0;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.home,
            color: currentTap == 0 ? MyConstant.dark : Colors.grey,
          ),
          /*Text(
            'Feed',
            style: GoogleFonts.prompt(
                color: currentTap == 0 ? MyConstant.dark : Colors.grey),
          ),*/
        ],
      ),
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
}
