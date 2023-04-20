import 'package:flutter/material.dart';

class MyConstant {
  static String appNameEN = 'insect pests';
  static String appNameTH = 'แมลงศัตรูพืช';
  static String domain = 'http://www.thianchaicham.lnw.mn';
  // User
  static String routeUser = '/rootUser';
  static String routeRegister = '/register';
  static String routeLogin = '/login';
  // Member
  static String routeEditProfileMember = '/editProfileMember';
  static String routeAccountMember = '/accountMember';
  static String routePostMember = '/postMember';
  static String routeMember = '/rootMember';
  // Admin
  static String routeAdmin = '/rootAdmin';

  //color
  static Color primary = Color(0xffA5C9CA);
  static Color light = Color(0xffE7F6F2);
  static Color dark = Color(0xff395B64);
  static Color dark2 = Color(0xff2C3333);
  //images
  static String image = 'images/image.png';
  static String avatar = 'images/avatar.png';
  static String imageChoose = 'images/image.png';
  static String add = 'images/adds.png';
  static String remove = 'images/remove.png';
  static String addImage = 'images/add_image.png';
  static String location = 'images/location.png';
  static String warning = 'images/warning.png';
  static String del = 'images/del.png';
  static String confirm = 'images/confirm.png';
  static String graph = 'images/graph.png';
  static String graph2 = 'images/graph2.png';
  static String editProfile = 'images/editProfile.png';
  static String map = 'images/map.png';

  String subImage(String string) {
    /// เอาภาพเดียว
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url = '${MyConstant.domain}/insectFile${strings[0]}';
    return url;
  }

  //Style
  TextStyle h1Style(Color color) => TextStyle(
        fontSize: 25,
        fontFamily: 'Kanit',
        color: color,
        fontWeight: FontWeight.bold,
      );
  TextStyle h2Style(Color color) => TextStyle(
        fontSize: 16,
        fontFamily: 'Kanit',
        color: color,
        fontWeight: FontWeight.normal,
      );
  TextStyle h3Style(Color color) => TextStyle(
        fontSize: 12,
        fontFamily: 'Kanit',
        color: color,
        fontWeight: FontWeight.normal,
      );
  //Button
  ButtonStyle myButtonStyle(Color colorfield, Color colorSide) =>
      ElevatedButton.styleFrom(
        primary: colorfield,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: colorSide, width: 2),
        ),
      );
}
