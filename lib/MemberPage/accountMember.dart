import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/MemberPage/Edit/showInsectData.dart';
import 'package:project001/MemberPage/Edit/showInsectLite.dart';
import 'package:project001/MemberPage/postMember.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountMember extends StatefulWidget {
  const AccountMember({Key? key}) : super(key: key);

  @override
  State<AccountMember> createState() => _AccountMemberState();
}

class _AccountMemberState extends State<AccountMember> {
  bool flagColor = true;
  bool load = true;
  bool load1 = true;
  bool load2 = true;
  bool? haveData;
  bool? haveData1;
  bool? haveData2;
  bool statusAvatar = true;

  List<EpidemicModel> epidemicModels = [];
  List<InsectModel> insectModels = [];
  UserModel? userModel;
  //EpidemicModel? epidemicModel;
  ////BottomSheet///////////

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    if (epidemicModels.length != 0) {
      epidemicModels.clear();
    } else {}
    if (insectModels.length != 0) {
      insectModels.clear();
    } else {}

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_user = preferences.getString('id')!;

    String apiGetInsectDataWhereId =
        '${MyConstant.domain}/insectFile/getInsectDataWhereIdUser.php?isAdd=true&id_user=$id_user';

    String apiGetInsectLiteWhereId =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereID.php?isAdd=true&id_user=$id_user';

    String apiGetUserWhereId =
        '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=$id_user';

    await Dio().get(apiGetUserWhereId).then((value) {
      for (var item in json.decode(value.data)) {
        setState(() {
          //load = false;
          //haveData = true;
          userModel = UserModel.fromMap(item);
          if (userModel!.img.isNotEmpty) {
            statusAvatar = true;
          } else {}
          if (userModel!.img.isEmpty) statusAvatar = false;
          print("User ID ==> ${userModel!.id}");
          print("User Img ==> ${userModel!.img}");
          print("User ==> ${userModel!.name}");
        });
      }
    });

    await Dio().get(apiGetInsectDataWhereId).then((value) {
      if (value.toString() == 'null') {
        // No Data
        setState(() {
          load = false;
          haveData = false;
        });
      } else {
        setState(() {
          load = false;
          haveData1 = true;
          print('## haveData1 => $haveData1');
        });
        // Have Data
        for (var item in json.decode(value.data)) {
          InsectModel model = InsectModel.fromMap(item);
          print('id InsectData ==>> ${model.id}');
          setState(() {
            load = false;
            insectModels.add(model);
          });
        }
      }
    });

    await Dio().get(apiGetInsectLiteWhereId).then((value) {
      if (value.toString() == 'null') {
        // No Data
        setState(() {
          // load = false;
          //haveData = false;
        });
      } else {
        // Have Data
        setState(() {
          haveData2 = true;
          print('## haveData2 => $haveData2');
        });
        for (var item in json.decode(value.data)) {
          EpidemicModel model = EpidemicModel.fromMap(item);
          print('id InsectLite ==>> ${model.id}');
          setState(() {
            //load = false;
            //haveData2 = true;
            epidemicModels.add(model);
          });
        }
      }
    });
    print('statusAvatar => $statusAvatar');
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: buildAppbar(),
      backgroundColor: Colors.white,
      body: load
          ? ShowProgress()
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    Container(
                      width: (constraints.maxWidth > 412)
                          ? (constraints.maxWidth * 0.6)
                          : constraints.maxWidth,
                      padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          statusAvatar != true
                              ? Container(
                                  child: Image.asset(
                                    MyConstant.avatar,
                                    scale: 5.6,
                                    color: Colors.grey[400],
                                  ),
                                )
                              : CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      '${MyConstant.domain}${userModel!.img}',
                                  placeholder: (context, url) => Container(
                                    child: Image.asset(
                                      MyConstant.avatar,
                                      scale: 5.6,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      ShowImage(path: MyConstant.image1),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: size * 0.23,
                                    height: size * 0.23,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                  ),
                                ),
                          /*CircleAvatar(
                                  radius: 45,
                                  backgroundImage: NetworkImage(
                                      '${MyConstant.domain}${userModel!.img}'),
                                  //AssetImage(MyConstant.avatar),
                                ),*/
                          buildNumber(size),
                          //buildButtonEditProfile(),
                          //buildButtonSingOut(),
                        ],
                      ),
                    ),
                    buildPersanal(constraints),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildButtonEditProfile(size),
                          buildButtonSingOut(size),
                        ],
                      ),
                    ),
                    Divider(
                        color: Colors.grey.shade100, thickness: 1, height: 1),
                    buidIconSelect(size),
                    flagColor
                        ? buildInsectData(context, constraints, size)
                        : buildInsectLite(context, constraints),
                  ],
                ),
              ),
            ),
    );
  }

  Container buildNumber(double size) {
    return Container(
      width: size * 0.6,
      height: 50,
      //color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${insectModels.length}',
                style:
                    GoogleFonts.jost(fontSize: 20, fontWeight: FontWeight.w600),
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
                '${epidemicModels.length}',
                style:
                    GoogleFonts.jost(fontSize: 20, fontWeight: FontWeight.w600),
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
                '${insectModels.length + epidemicModels.length}',
                style:
                    GoogleFonts.jost(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                'ทั้งหมด',
                style: GoogleFonts.prompt(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox buidIconSelect(double size) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: flagColor ? Colors.white : Colors.grey[300],
            ),
            width: size * 0.5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  flagColor = true;
                });
              },
              icon: Text(
                'ข้อมูลแมลง',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: flagColor ? Colors.grey[300] : Colors.white,
            ),
            width: size * 0.5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  flagColor = false;
                });
              },
              icon: Text(
                'ข้อมูลการพบแมลง',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* LayoutBuilder showNoData(double size) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Container(
            width: (constraints.maxWidth > 412)
                ? (constraints.maxWidth * 0.6)
                : constraints.maxWidth,
            padding:
                EdgeInsets.only(top: 48, bottom: 16, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                statusAvatar != true
                    ? Container(
                        child: Image.asset(
                          MyConstant.avatar,
                          scale: 5.6,
                          color: Colors.grey[400],
                        ),
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            '${MyConstant.domain}${userModel!.img}'),
                        //AssetImage(MyConstant.avatar),
                      ),
                buildButtonEditProfile(),
                buildButtonSingOut(),
              ],
            ),
          ),
          buildPersanal(constraints),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
          ),
          buidIconSelect(size),
          flagColor
              ? Padding(
                  padding: const EdgeInsets.all(120),
                  child: Center(
                    child: Text(
                      'Empty',
                      style: GoogleFonts.prompt(
                        fontSize: 22,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(120),
                  child: Center(
                    child: Text(
                      'Empty',
                      style: GoogleFonts.prompt(
                        fontSize: 22,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }*/

  Expanded buildInsectData(
      BuildContext context, BoxConstraints constraints, double size) {
    return Expanded(
        child: MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Container(
        child: GridView.builder(
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
                    builder: (context) =>
                        ShowInsectData(insectModel: insectModels[index]),
                  ),
                ).then((value) => loadValueFromAPI());
                //showInsectLiteFormIndex(context);
                print('send ======> id ${insectModels[index].id}');
              },
              child: Container(
                width: constraints.maxWidth * 0.5,
                height: constraints.maxWidth * 0.4,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: createUrl(insectModels[index].img),
                  placeholder: (context, url) => ShowProgress(),
                  errorWidget: (context, url, error) =>
                      ShowImage(path: MyConstant.image1),
                ),
              ),
            ); //Image.asset(MyConstant.image, fit: BoxFit.cover),
          },
        ),
      ),
    ));
  }

  Expanded buildInsectLite(BuildContext context, BoxConstraints constraints) {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Container(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (constraints.maxWidth > 412) ? 4 : 3,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemCount: epidemicModels.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowInsectLite(epidemicModel: epidemicModels[index]),
                    ),
                  ).then((value) => loadValueFromAPI());
                  //showInsectLiteFormIndex(context);
                  print('send ======> id ${epidemicModels[index].id}');
                },
                child: Container(
                  width: constraints.maxWidth * 0.5,
                  height: constraints.maxWidth * 0.4,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: createUrl(epidemicModels[index].img),
                    placeholder: (context, url) => ShowProgress(),
                    errorWidget: (context, url, error) =>
                        ShowImage(path: MyConstant.image1),
                  ),
                ),
              ); //Image.asset(MyConstant.image, fit: BoxFit.cover),
            },
          ),
        ),
      ),
    );
  }

  Container buildPersanal(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      width: (constraints.maxWidth > 412)
          ? (constraints.maxWidth * 0.6)
          : constraints.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            userModel == null ? "name?" : userModel!.name,
            style: GoogleFonts.prompt(
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            '${userModel!.phone}',
            style: GoogleFonts.prompt(
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            '${userModel!.email}',
            style: GoogleFonts.prompt(
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "${userModel!.county} ${userModel!.district} ${userModel!.province}",
            style: GoogleFonts.prompt(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  OutlineButton buildButtonEditProfile(double size) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        Navigator.pushNamed(context, MyConstant.routeEditProfileMember)
            .then((value) {
          refreshUserModel();
          loadValueFromAPI();
        });
      },
      child: Container(
        width: size * 0.52,
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

  RaisedButton buildButtonSingOut(double size) {
    return RaisedButton(
      onPressed: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.clear().then(
              (value) => Navigator.pushNamedAndRemoveUntil(
                  context, MyConstant.routeUser, (route) => false),
            );
      },
      color: MyConstant.dark,
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        width: size * 0.1,
        child: Icon(
          FontAwesomeIcons.signOut,
          color: MyConstant.primary,
          size: 14,
        ),
      ),
    );
  }

  Future<Null> refreshUserModel() async {
    print('## refreshUserModel Work');
    String apiGetUserWhereId =
        '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=${userModel!.id}';
    await Dio().get(apiGetUserWhereId).then((value) {
      for (var item in json.decode(value.data)) {
        setState(() {
          userModel = UserModel.fromMap(item);
        });
      }
    });
  }

  String createUrl(String string) {
    /// เอาภาพเดียว
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url = '${MyConstant.domain}/insectFile${strings[0]}';

    return url;
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
          Text(
            'Profile',
            style: GoogleFonts.lobster(
              fontSize: 30,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostMember(),
              ),
            );
          },
          icon: Icon(FontAwesomeIcons.plusSquare),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(FontAwesomeIcons.alignJustify),
        ),
      ],
    );
  }

  /////////////////////////BottomSheet///////////////////////////////////////

}
