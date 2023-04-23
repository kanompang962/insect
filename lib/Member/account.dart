import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Member/showInsectData.dart';
import 'package:project001/Member/showInsectLite.dart';
import 'package:project001/User/post.dart';
import 'package:project001/model/insectLite_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool flagColor = true;
  bool loadIn = true;
  bool loadInl = true;
  bool load = true;
  bool? haveData;
  bool statusAvatar = false;

  List<InsectLiteModel> insectLiteModels = [];
  List<InsectModel> insectModels = [];
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
    loadInsectDataFromAPI();
    loadInsectLiteFromAPI();
  }

  Future<Null> loadInsectLiteFromAPI() async {
    if (insectLiteModels.length != 0) {
      insectLiteModels.clear();
    } else {}

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_user = preferences.getString('id')!;

    String apiGetInsectLiteWhereId =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereID.php?isAdd=true&id_user=$id_user';
    try {
      await Dio().get(apiGetInsectLiteWhereId).then((value) {
        if (value.toString() == 'null') {
          print('### no value insect');
        } else {
          for (var item in json.decode(value.data)) {
            InsectLiteModel model = InsectLiteModel.fromMap(item);
            setState(() {
              insectLiteModels.add(model);
            });
          }
          setState(() {
            loadInl = false;
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  Future<Null> loadInsectDataFromAPI() async {
    print('### old list ==> ${insectModels.length}');
    if (insectModels.length != 0) {
      insectModels.clear();
    } else {}

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_user = preferences.getString('id')!;

    String apiGetInsectDataWhereId =
        '${MyConstant.domain}/insectFile/getInsectDataWhereIdUser.php?isAdd=true&id_user=$id_user';
    try {
      await Dio().get(apiGetInsectDataWhereId).then((value) {
        if (value.toString() == 'null') {
          print('### no value insect');
        } else {
          for (var item in json.decode(value.data)) {
            InsectModel model = InsectModel.fromMap(item);
            setState(() {
              insectModels.add(model);
            });
          }
          setState(() {
            loadIn = false;
            print('### new list ==> ${insectModels.length}');
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  Future<Null> loadValueFromAPI() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_user = preferences.getString('id')!;

    String apiGetUserWhereId =
        '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=$id_user';
    try {
      await Dio().get(apiGetUserWhereId).then((value) {
        if (value.toString() == 'null') {
          print('value ==> null');
          _functionSignOut();
        } else {
          for (var item in json.decode(value.data)) {
            setState(() {
              userModel = UserModel.fromMap(item);
              print('### User ==> $userModel');
              if (userModel!.img != 'null') statusAvatar = true;
              load = false;
            });
          }
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
    print('### statusAvatar => $statusAvatar');
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: buildAppbar(),
      backgroundColor: Colors.white,
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: (constraints.maxWidth > 412)
                          ? (constraints.maxWidth * 0.8)
                          : constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.only(top: 10, left: 20, right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildHeader(constraints, size),
                                buildCenter(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildButtonEditProfile(size),
                                    buildButtonSingOut(size),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          buildMenu(constraints),
                          flagColor
                              ? buildInsectData(context, constraints)
                              : buildInsectLite(context, constraints),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

// function
  Future<Null> _functionSignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear().then(
          (value) => Navigator.pushNamedAndRemoveUntil(
              context, MyConstant.routeUser, (route) => false),
        );
  }

// Widget
  Widget buildInsectData(BuildContext context, BoxConstraints constraints) {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Container(
          child: insectModels.isNotEmpty
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (constraints.maxWidth > 412) ? 4 : 3,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemCount: insectModels.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowInsectData(
                                insectModel: insectModels[index]),
                          ),
                        ).then((value) => loadInsectDataFromAPI());
                        //showInsectLiteFormIndex(context);
                        print(
                            '### Send InsectID ==> ${insectModels[index].id}');
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.5,
                        height: constraints.maxWidth * 0.4,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              MyConstant().subImage(insectModels[index].img),
                          placeholder: (context, url) =>
                              ShowImage(path: MyConstant.image),
                          errorWidget: (context, url, error) =>
                              ShowImage(path: MyConstant.image),
                        ),
                      ),
                    ); //Image.asset(MyConstant.image, fit: BoxFit.cover),
                  },
                )
              : Container(
                  width: constraints.maxWidth * 0.2,
                  height: constraints.maxWidth * 0.2,
                  child: Image.asset(
                    'images/adds.png',
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildInsectLite(BuildContext context, BoxConstraints constraints) {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Container(
          child: insectLiteModels.length > 0
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (constraints.maxWidth > 412) ? 4 : 3,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemCount: insectLiteModels.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print('### latLng ==> ${insectLiteModels[index].lat}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowInsectLite(
                                insectLiteModel: insectLiteModels[index]),
                          ),
                        ).then((value) => loadInsectLiteFromAPI());
                        // showInsectLiteFormIndex(context);
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.5,
                        height: constraints.maxWidth * 0.4,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: MyConstant()
                              .subImage(insectLiteModels[index].img),
                          placeholder: (context, url) =>
                              ShowImage(path: MyConstant.image),
                          errorWidget: (context, url, error) =>
                              ShowImage(path: MyConstant.image),
                        ),
                      ),
                    ); //Image.asset(MyConstant.image, fit: BoxFit.cover),
                  },
                )
              : Container(
                  width: constraints.maxWidth * 0.2,
                  height: constraints.maxWidth * 0.2,
                  child: Image.asset(
                    'images/adds.png',
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildMenu(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                flagColor = true;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'ข้อมูลแมลง',
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  color: flagColor ? Colors.grey[500] : Colors.white,
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8) / 2
                      : (constraints.maxWidth) / 2,

                  // (constraints.maxWidth) / 2,
                  height: 1,
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                flagColor = false;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'ข้อมูลการพบแมลง',
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  color: flagColor ? Colors.white : Colors.grey[500],
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8) / 2
                      : (constraints.maxWidth) / 2,
                  height: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCenter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${userModel!.name}',
            style: GoogleFonts.prompt(fontSize: 12),
          ),
          Text(
            '${userModel!.phone}',
            style: GoogleFonts.prompt(fontSize: 12),
          ),
          Text(
            '${userModel!.email}',
            style: GoogleFonts.prompt(fontSize: 12),
          ),
          Text(
            "${userModel!.county} ${userModel!.district} ${userModel!.province}",
            style: GoogleFonts.prompt(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BoxConstraints constraints, double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: '${MyConstant.domain}${userModel!.img}',
          placeholder: (context, url) => Container(
            width: (constraints.maxWidth > 412) ? size * 0.1 : size * 0.2,
            height: (constraints.maxWidth > 412) ? size * 0.1 : size * 0.2,
            child: Image.asset(
              MyConstant.avatar,
              color: Colors.grey[400],
            ),
          ),
          errorWidget: (context, url, error) =>
              ShowImage(path: MyConstant.avatar),
          imageBuilder: (context, imageProvider) => Container(
            width: (constraints.maxWidth > 412) ? size * 0.15 : size * 0.2,
            height: (constraints.maxWidth > 412) ? size * 0.15 : size * 0.2,
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        Container(
          width: size * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${insectModels.length}',
                    style: GoogleFonts.jost(fontSize: 14),
                  ),
                  Text(
                    'แมลง',
                    style: GoogleFonts.prompt(),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${insectLiteModels.length}',
                    style: GoogleFonts.jost(fontSize: 14),
                  ),
                  Text(
                    'พบแมลง',
                    style: GoogleFonts.prompt(),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${insectModels.length + insectLiteModels.length}',
                    style: GoogleFonts.jost(fontSize: 14),
                  ),
                  Text(
                    'ทั้งหมด',
                    style: GoogleFonts.prompt(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButtonEditProfile(double size) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        Navigator.pushNamed(context, MyConstant.routeEditProfileMember)
            .then((value) => loadValueFromAPI());
      },
      child: Container(
        width: size * 0.46,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "แก้ไขโปรไฟล์",
              style: GoogleFonts.prompt(
                fontSize: 14,
                //fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonSingOut(double size) {
    return RaisedButton(
      onPressed: () async {
        _functionSignOut();
      },
      color: Color(0xFF800000),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        // width: size * 0.1,
        child: Icon(
          FontAwesomeIcons.rightFromBracket,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.unlock,
            size: 18,
          ),
          Row(
            children: [
              Text(
                'Profile',
                style: GoogleFonts.lobster(
                  fontSize: 30,
                ),
              ),
              Text(
                ' | ข้อมูลโปรไฟล์',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Post(),
              ),
            ).then((value) {
              loadInsectDataFromAPI();
              loadInsectLiteFromAPI();
            });
          },
          icon: Icon(FontAwesomeIcons.plusSquare),
        ),
        // IconButton(
        //   onPressed: () {},
        //   icon: Icon(FontAwesomeIcons.alignJustify),
        // ),
      ],
    );
  }
}
