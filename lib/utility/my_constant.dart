import 'package:flutter/material.dart';

class MyConstant {
  static String appNameEN = 'insect pests';
  static String appNameTH = 'แมลงศัตรูพืช';
  static String domain =
      'http://d0d6-183-88-156-172.ngrok.io';
  //User
  static String routeUser = '/rootUser';
  static String routeCreateAccount = '/createAccount';
  static String routeAccountUser = '/accountUser';
  //Member
  static String routeEditProfileMember = '/editProfileMember';
  //static String routeEditInsectLiteMember = '/editInsectLiteMember';
  static String routeAccountMember = '/accountMember';
  static String routePostMember = '/postMember';
  static String routeMember = '/rootMember';
  //Expert
  //static String routeExpert = '/rootExpert';
  //static String routeAccountDevelop = '/accountExpert';
 
  //color
  static Color primary = Color(0xffA5C9CA);
  static Color light = Color(0xffE7F6F2);
  static Color dark = Color(0xff395B64);
  static Color dark2 = Color(0xff2C3333);

  static Color colorMenu2 = Color(0xffC1CC53);
  static Color colorMenu3 = Color(0xffB19137);
  static Color colorMenu4 = Color(0xffB02C04);

  //images
  static String image = 'images/image.png';
  static String image1 = 'images/image1.png';
  static String image2 = 'images/image2.png';
  static String image3 = 'images/image3.png';
  static String image4 = 'images/image4.png';
  static String avatar = 'images/avatar.png';
  static String apple = 'images/apple.png';
  static String coca = 'images/coca.png';
  static String leaves = 'images/leaves.png';
  static String trunk = 'images/trunk.png';
  static String imageChoose = 'images/image.png';
  static String add = 'images/adds.png';
  static String remove = 'images/remove.png';
  static String addImage = 'images/add_image.png';
  static String flower = 'images/flower.png';
  static String root = 'images/root.png';
  static String bug = 'images/bug.png';
  static String location = 'images\location.png';

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

  List posts = [
    {
      "id": 1,
      "name": "panhchaneath_ung",
      "profileImg":
          "https://images.unsplash.com/photo-1503185912284-5271ff81b9a8?ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Z2lybHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
      "postImg":
          "https://images.unsplash.com/photo-1503185912284-5271ff81b9a8?ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Z2lybHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    },
    {
      "id": 2,
      "name": "whereavygoes",
      "profileImg":
          "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Z2lybHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
      "postImg":
          "https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510__340.jpg",
    },
    {
      "id": 3,
      "name": "allef_vinicius",
      "profileImg":
          "https://images.unsplash.com/photo-1545912452-8aea7e25a3d3?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60",
      "postImg":
          "https://images.unsplash.com/photo-1578616070222-50c4de9d5ade?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60",
    },
    {
      "id": 4,
      "name": "babysweetiepie",
      "profileImg":
          "https://images.unsplash.com/photo-1513207565459-d7f36bfa1222?ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8Z2lybHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
      "postImg":
          "https://images.unsplash.com/photo-1513207565459-d7f36bfa1222?ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8Z2lybHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    }
  ];
}
