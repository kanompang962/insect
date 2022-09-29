import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/MemberPage/FeedState/showDetails1.dart';
import 'package:project001/MemberPage/FeedState/showDetails2.dart';
import 'package:project001/MemberPage/FeedState/showMap1.dart';
import 'package:project001/MemberPage/FeedState/showMap2.dart';
import 'package:project001/MemberPage/FeedState/verifyPage.dart';
import 'package:project001/MemberPage/postMember.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMember extends StatefulWidget {
  const HomeMember({Key? key}) : super(key: key);

  @override
  _HomeMemberState createState() => _HomeMemberState();
}

class _HomeMemberState extends State<HomeMember> {
  bool load1 = true;
  bool load2 = true;
  bool? haveData1;
  bool? haveData2;
  List<EpidemicModel> epidemicModels = [];
  List<InsectModel> insectModels = [];
  //List<UserModel> userModels = [];
  Map<String, String> userImage = {};
  Map<String, String> userName = {};
  Map<String, String> userEmail = {};
  bool avater = false;
  bool name = false;
  bool email = false;
  bool flagColor = true;
  String? typeUser;

  @override
  void initState() {
    super.initState();
    //loadEpidemicFromAPI();
    loadInsectFromAPI();
    checkTypeUser();
  }

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    typeUser = preferences.getString('type');
  }

  Future<Null> loadUserFromAPI(String id) async {
    String apiGetUserWhereId =
        '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=$id';
    await Dio().get(apiGetUserWhereId).then(
      (value) {
        if (value != null) {
          avater = true;
        }
        for (var item in json.decode(value.data)) {
          UserModel model = UserModel.fromMap(item);
          setState(() {
            userImage['$id'] = '${model.img}';
            userName['$id'] = '${model.name}';
            userEmail['$id'] = '${model.email}';
            //print('UserList => ${userImage['$id']}');
            if (model.img.isNotEmpty) {
              avater = true;
              name = true;
              email = true;
            }
          });
        }
      },
    );
  }

  Future<Null> loadInsectFromAPI() async {
    if (insectModels.length != 0) {
      insectModels.clear();
    } else {}

    String apiGetValues =
        '${MyConstant.domain}/insectFile/getInsectData.php?isAdd=true';

    await Dio().get(apiGetValues).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('No Data1');
        setState(() {
          avater = false;
          load1 = false;
          haveData1 = true;
        });
      } else {
        // Have Data
        print('Have Data');
        for (var item in json.decode(value.data)) {
          //EpidemicModel model = EpidemicModel.fromMap(item);
          InsectModel model = InsectModel.fromMap(item);
          //loadUserFromAPI(model.id_user);
          setState(() {
            insectModels.add(model);
          });
        }
        // avater = true;
        print('StatusAvartar => $avater');
      }
    });
  }

  /*Future<Null> loadEpidemicFromAPI() async {
    if (epidemicModels.length != 0) {
      epidemicModels.clear();
    } else {}

    String apiGetValues =
        '${MyConstant.domain}/insectFile/getInsectlite.php?isAdd=true';

    await Dio().get(apiGetValues).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('No Data');
        setState(() {
          load2 = false;
          haveData2 = true;
        });
      } else {
        // Have Data
        print('Have Data');
        for (var item in json.decode(value.data)) {
          EpidemicModel model = EpidemicModel.fromMap(item);
          setState(() {
            epidemicModels.add(model);
          });
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      body: load1
          ? LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Divider(
                        color: Colors.grey.shade100, thickness: 1, height: 1),
                    buidIconSelect(size),
                    SizedBox(
                      height: 3,
                    ),*/
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Container(
                            width: (constraints.maxWidth > 412)
                                ? (constraints.maxWidth * 0.5)
                                : constraints.maxWidth,
                            child: flagColor
                                ? buildInsectValue()
                                : Container()), //buildEpidemicValue()),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ShowProgress(),
    );
  }

  ListView buildInsectValue() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: insectModels.length,
      itemBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    buildHeader(index),
                    buildImage(constraints, index),
                    buildDetails(constraints, index),
                    Divider(
                      color: Colors.grey.shade100,
                      thickness: 1,
                      height: 1,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 8.0,
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            buildButtonDetails(index),
                          ],
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            buildButtonMap(index),
                          ],
                        ),
                        Spacer(),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            //Text(insectModels[index].date),
                          ],
                        ),
                        SizedBox(width: 8.0)
                      ],
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  /* ListView buildEpidemicValue() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: epidemicModels.length,
      itemBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  buildHeader(index),
                  buildImage(constraints, index),
                  buildDetails(constraints, index),
                  Row(
                    children: [
                      SizedBox(
                        width: 8.0,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          buildButtonDetails(index),
                        ],
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          buildButtonMap(index),
                        ],
                      ),
                      Spacer(),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          typeUser == 'Expert'
                              ? buildButtonVerify(index)
                              : Container(),
                          SizedBox(width: 8.0)
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }*/

  /*SizedBox buidIconSelect(double size) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
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
  }*/

  /* RaisedButton buildButtonVerify(int index) {
    return RaisedButton(
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerifyPage(epidemicModel: epidemicModels[index]),
          ),
        ).then((value) {
          //loadEpidemicFromAPI();
          loadInsectFromAPI();
        });
        //showInsectLiteFormIndex(context);
        print('send ======> id ${epidemicModels[index].id}');
      },
      color: Colors.lightBlue[600],
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "VERIFY",
        style: TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.white),
      ),
    );
  }*/

  RaisedButton buildButtonDetails(int index) {
    return RaisedButton(
      onPressed: () async {
        if (flagColor) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShowDetails1(insectModel: insectModels[index]),
            ),
          ).then((value) => false);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShowDetails2(epidemicModel: epidemicModels[index]),
            ),
          ).then((value) => false);
        }
      },
      color: MyConstant.dark,
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "DETAILS",
        style: GoogleFonts.jost(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 2.2,
        ),
      ),
    );
  }

  OutlineButton buildButtonMap(int index) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        print('Click--->Map');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => flagColor
                    ? ShowMap1(insectModel: insectModels[index])
                    : ShowMap2(epidemicModel: epidemicModels[index])));
      },
      child: Text(
        "MAP",
        style: GoogleFonts.jost(
          fontWeight: FontWeight.w500,
          color: MyConstant.dark,
          letterSpacing: 2.2,
        ),
      ),
    );
  }

  Container buildImage(BoxConstraints constraints, int index) {
    return Container(
      height: constraints.maxWidth,
      // replace image
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: insectModels[index].img.isNotEmpty
            ? createUrl(insectModels[index].img)
            : MyConstant.image,
        /*flagColor
            ? createUrl(insectModels[index].img)
            : createUrl(epidemicModels[index].img),*/
        placeholder: (context, url) => ShowProgress(),
        errorWidget: (context, url, error) =>
            ShowImage(path: MyConstant.image),
      ),
    );
  }

  Container buildDetails(BoxConstraints constraints, int index) {
    return Container(
      width: constraints.maxWidth,
      padding: EdgeInsets.all(8.0),
      // replace post description
      child: flagColor
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                  child: Text(
                    '${insectModels[index].name}',
                    style: GoogleFonts.prompt(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${insectModels[index].details}',
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                      child: Text(
                        '${epidemicModels[index].name}',
                        style: GoogleFonts.prompt(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "วันที่: ${epidemicModels[index].date}",
                      style: GoogleFonts.prompt(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "เวลา: ${epidemicModels[index].time}",
                      style: GoogleFonts.prompt(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Text(
                  "พบในพื้นที่: ต.${epidemicModels[index].county} อ.${epidemicModels[index].district} จ.${epidemicModels[index].province}",
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }

  Container buildHeader(int index) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          // replace avatar image here
          /* userImage['${insectModels[index].id_user}']!.isNotEmpty
              ? */
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('images/avatar.png'),
            backgroundColor: Colors.grey,
          ),
          /* avater != true
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('images/avatar.png'),
                  backgroundColor: Colors.grey,
                )
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl:
                      '${MyConstant.domain}${userImage['${insectModels[index].id_user}']}',
                  placeholder: (context, url) => CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('images/avatar.png'),
                    backgroundColor: Colors.grey,
                  ),
                  errorWidget: (context, url, error) =>
                      ShowImage(path: MyConstant.image1),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                ),*/
          /*avater == true
              ? Container(
                  child: avater
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              '${MyConstant.domain}${userImage['${insectModels[index].id_user}']}'),
                          //AssetImage(MyConstant.avatar),
                        )
                      : CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('images/avatar.png'),
                          // NetworkImage(
                          //  '${MyConstant.domain}${userImage['${insectModels[index].id_user}']}'),
                        ),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('images/avatar.png'),
                  // NetworkImage(
                  //  '${MyConstant.domain}${userImage['${insectModels[index].id_user}']}'),
                ),*/

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 16.0),
                // replace display name here
                child: name == true
                    ? Text(
                        "${userName['${insectModels[index].id_user}']}",
                        style: GoogleFonts.jost(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        "name",
                        style: GoogleFonts.jost(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: email == true
                      ? Text(
                          "${userEmail['${insectModels[index].id_user}']}",
                          style: GoogleFonts.jost(
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          "name",
                          style: GoogleFonts.jost(
                            fontSize: 12,
                          ),
                        )

                  /*flagColor
                    ? Text(insectModels[index].id_user)
                    : Text(epidemicModels[index].id_user),*/
                  )
            ],
          ),
        ],
      ),
    );
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
      title: Text(
        'Insect',
        style: GoogleFonts.lobster(
          fontSize: 30,
        ),
      ),
      actions: [
        typeUser == null
        ?Container()
        :IconButton(
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
      ],
    );
  }
}
