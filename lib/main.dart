import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project001/Admin/root/rootAdmin.dart';
import 'package:project001/Member/editProfile.dart';
import 'package:project001/Member/account.dart';
import 'package:project001/User/menu.dart';
import 'package:project001/User/post.dart';
import 'package:project001/Member/root/rootMember.dart';
import 'package:project001/User/login.dart';
import 'package:project001/User/register.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'User/root/rootUser.dart';

final Map<String, WidgetBuilder> map = {
  // User
  '/rootUser': (BuildContext context) => RootUser(),
  '/register': (BuildContext context) => Register(),
  '/login': (BuildContext context) => Login(),
  // Member
  '/rootMember': (BuildContext context) => RootMember(),
  '/editProfileMember': (BuildContext context) => EditProfile(),
  '/postMember': (BuildContext context) => Post(),
  '/menuMember': (BuildContext context) => Menu(),
  '/accountMember': (BuildContext context) => Account(),
  // Admin
  '/rootAdmin': (BuildContext context) => RootAdmin(),
};
String? initlalRoute;

Future<Null> main() async {
  // ไม่ให้ใช้จอแนวนอน
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  // เช็คสถานะผู้ใช้
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? type = preferences.getString('type');
  print('### UserType ==> $type');
  switch (type) {
    case 'Member':
      initlalRoute = MyConstant.routeMember;
      runApp(MyApp());
      break;
    case 'Expert':
      initlalRoute = MyConstant.routeMember;
      runApp(MyApp());
      break;
    case 'Admin':
      initlalRoute = MyConstant.routeAdmin;
      runApp(MyApp());
      break;
    default:
      initlalRoute = MyConstant.routeUser;
      runApp(MyApp());
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
