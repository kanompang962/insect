import 'package:flutter/material.dart';
import 'package:project001/MemberPage/Edit/editProfileMember.dart';
import 'package:project001/MemberPage/accountMember.dart';
import 'package:project001/MemberPage/menuMember.dart';
import 'package:project001/MemberPage/postMember.dart';
import 'package:project001/MemberPage/rootMember.dart';
import 'package:project001/UserPage/accountUser.dart';
import 'package:project001/UserPage/create_account.dart';
import 'package:project001/UserPage/menuUser.dart';
import 'package:project001/UserPage/rootUser.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, WidgetBuilder> map = {
  //User
  '/createAccount': (BuildContext context) => CreateAccount(),
  '/rootUser': (BuildContext context) => RootUser(),
  '/menuUser': (BuildContext context) => MenuUser(),
  '/accountUser': (BuildContext context) => AccountUser(),
  //Member
  '/editProfileMember': (BuildContext context) => EditProfileMember(),
  //'/editInsectLiteMember': (BuildContext context) => EditInsectLiteMember(epidemicModel: Null),

  '/postMember': (BuildContext context) => PostMember(),
  '/rootMember': (BuildContext context) => RootMember(),
  '/menuMember': (BuildContext context) => MenuMember(),
  '/accountMember': (BuildContext context) => AccountMember(),
  //Expert
  //'/rootExpert': (BuildContext context) => RootExpert(),
  //'/accountExpert': (BuildContext context) => AccountExpert(),
};
String? initlalRoute;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? type = preferences.getString('type');
  print('### type ===>> $type');
  if (type?.isEmpty ?? true) {
    initlalRoute = MyConstant.routeUser;
    runApp(MyApp());
  } else {
    initlalRoute = MyConstant.routeMember;
    runApp(MyApp());
    /*switch (type) {
      case 'Member':
        initlalRoute = MyConstant.routeMember;
        runApp(MyApp());
        break;
      case 'Expert':
        initlalRoute = MyConstant.routeExpert;
        runApp(MyApp());
        break;
      default:
    }*/
  }
  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyConstant.appNameEN,
      routes: map,
      initialRoute: initlalRoute,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
    );
  }
}
