import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool statusRedEye = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: Form(
                key: formKey,
                child: Container(
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8)
                      : constraints.maxWidth,
                  child: ListView(
                    children: [
                      buildAppName(),
                      buildUser(size),
                      buildPassword(size),
                      buildButtonLogin(size), //buidLogin(size),
                      // buildButtonFb(size), //buidLogin(size),
                      buildRegister(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// function
  Future<Null> checkAuthen({String? username, String? password}) async {
    String apiCheckAuthen =
        '${MyConstant.domain}/insectFile/getUserWhereUser.php?isAdd=true&username=$username';
    try {
      await Dio().get(apiCheckAuthen).then((value) async {
        print('## value for API ==>> $value');
        if (value.toString() == 'null') {
          MyDialog().normalDialog(context, 'ชื่อผู้ใช้นี้ ไม่มีในในระบบ',
              'This username does not exist in the system.');
        } else {
          for (var item in json.decode(value.data)) {
            UserModel model = UserModel.fromMap(item);
            if (password == model.password) {
              // Success Authen
              String type = model.type;
              print('## Authen Success in Type ==> $type');
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.setString('id', model.id);
              preferences.setString('username', model.username);
              preferences.setString('name', model.name);
              preferences.setString('img', model.img);
              preferences.setString('email', model.email);
              preferences.setString('phone', model.phone);
              preferences.setString('county', model.county);
              preferences.setString('district', model.district);
              preferences.setString('province', model.province);
              preferences.setString('type', model.type);
              // Navigator.pushNamedAndRemoveUntil(
              //     context, MyConstant.routeMember, (route) => false);
              switch (type) {
                case 'Member':
                  Navigator.pushNamedAndRemoveUntil(
                      context, MyConstant.routeMember, (route) => false);
                  break;
                case 'Expert':
                  Navigator.pushNamedAndRemoveUntil(
                      context, MyConstant.routeMember, (route) => false);
                  break;
                case 'Admin':
                  Navigator.pushNamedAndRemoveUntil(
                      context, MyConstant.routeAdmin, (route) => false);
                  break;
                default:
              }
            } else {
              MyDialog().normalDialog(context, 'รหัสผ่านไม่ถูกต้อง',
                  'Password False Please Try Again');
            }
          }
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

// Widget

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        '',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'iannnnn-DUCK',
          fontWeight: FontWeight.w900,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget buildRegister(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'หากคุณยังไม่มีบัญชี',
          style: GoogleFonts.prompt(),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, MyConstant.routeRegister),
          child: Text(
            'ลงทะเบียน',
            style: GoogleFonts.prompt(
              color: MyConstant.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButtonLogin(double size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 80),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: RaisedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            String username = userController.text;
            String password = passwordController.text;
            print('## user = $username, password = $password');
            checkAuthen(username: username, password: password);
          }
        },
        color: MyConstant.primary,
        padding: EdgeInsets.symmetric(horizontal: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Text(
          "เข้าสู่ระบบ",
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildButtonFb(double size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 80),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: RaisedButton(
        onPressed: () {},
        color: Colors.blue[900],
        padding: EdgeInsets.symmetric(horizontal: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Text(
          "FACEBOOK",
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildUser(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(top: 16),
            width: size * 0.6,
            child: TextFormField(
              controller: userController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'กรุณากรอกข้อมูลให้ครบ';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                labelStyle: MyConstant().h3Style(MyConstant.dark),
                labelText: 'ชื่อผู้ใช้ :',
                prefixIcon: Icon(
                  Icons.account_circle_rounded,
                  color: MyConstant.dark,
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyConstant.dark),
                    borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyConstant.light),
                    borderRadius: BorderRadius.circular(30)),
              ),
            )),
      ],
    );
  }

  Widget buildPassword(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(top: 16),
            width: size * 0.6,
            child: TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'กรุณากรอกข้อมูลให้ครบ';
                } else {
                  return null;
                }
              },
              obscureText: statusRedEye,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      statusRedEye = !statusRedEye;
                    });
                  },
                  icon: statusRedEye
                      ? Icon(
                          Icons.remove_red_eye,
                          color: MyConstant.dark,
                        )
                      : Icon(
                          Icons.remove_red_eye_outlined,
                          color: MyConstant.dark,
                        ),
                ),
                labelStyle: MyConstant().h3Style(MyConstant.dark),
                labelText: 'รหัสผ่าน :',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: MyConstant.dark,
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyConstant.dark),
                    borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyConstant.light),
                    borderRadius: BorderRadius.circular(30)),
              ),
            )),
      ],
    );
  }

  Widget buildAppName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              MyConstant.appNameEN,
              style: TextStyle(
                color: MyConstant.dark,
                fontSize: 60,
                fontWeight: FontWeight.bold,
                fontFamily: 'iannnnn-DUCK',
              ),
            ),
            Text(
              MyConstant.appNameTH,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'iannnnn-DUCK',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
