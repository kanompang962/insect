import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountUser extends StatefulWidget {
  const AccountUser({Key? key}) : super(key: key);

  @override
  _AccountUserState createState() => _AccountUserState();
}

class _AccountUserState extends State<AccountUser> {
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
          child: Form(
            key: formKey,
            child: Container(
              child: ListView(
                children: [
                  buildAppName(),
                  buildUser(size),
                  buildPassword(size),
                  buildButtonLogin(size), //buidLogin(size),
                  buildCreateAccount(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> checkAuthen({String? username, String? password}) async {
    String apiCheckAuthen =
        '${MyConstant.domain}/insectFile/getUserWhereUser.php?isAdd=true&username=$username';
    await Dio().get(apiCheckAuthen).then((value) async {
      print('## value for API ==>> $value');
      if (value.toString() == 'null') {
        MyDialog().normalDialog(
            context, 'User False !!!', 'No $username in my Database');
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
            Navigator.pushNamedAndRemoveUntil(
                    context, MyConstant.routeMember, (route) => false);
            /*switch (type) {
              case 'Member':
                Navigator.pushNamedAndRemoveUntil(
                    context, MyConstant.routeMember, (route) => false);
                break;
              case 'Expert':
                Navigator.pushNamedAndRemoveUntil(
                    context, MyConstant.routeExpert, (route) => false);
                break;
              default:
            }*/
          } else {
            // Authen False
            MyDialog().normalDialog(context, 'Password False !!!',
                'Password False Please Try Again');
          }
        }
      }
    });
  }

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

  Row buildCreateAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          MyConstant.appNameEN,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, MyConstant.routeCreateAccount),
          child: Text(
            'Create Account',
            style: TextStyle(
              color: MyConstant.light,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
        ),
      ],
    );
  }

  Container buildButtonLogin(double size) {
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
          "LOGIN",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.white),
        ),
      ),
    );
  }

  Row buildUser(double size) {
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
                  return 'Please Fill User in Blank';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                labelStyle: MyConstant().h3Style(MyConstant.dark),
                labelText: 'User :',
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

  Row buildPassword(double size) {
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
                  return 'Please Fill Password in Blank';
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
                labelText: 'Password :',
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

  Row buildAppName() {
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
