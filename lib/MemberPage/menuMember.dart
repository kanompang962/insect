import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/MemberPage/Edit/showInsectData.dart';
import 'package:project001/MemberPage/Edit/showInsectLite.dart';
import 'package:project001/MemberPage/FeedState/showDetails1.dart';
import 'package:project001/MemberPage/searchMember.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuMember extends StatefulWidget {
  const MenuMember({Key? key}) : super(key: key);

  @override
  State<MenuMember> createState() => _MenuMemberState();
}

class _MenuMemberState extends State<MenuMember> {
  bool flagColor = true;
  bool status = false;
  bool load = true;
  bool load1 = true;
  bool load2 = true;
  bool? haveData;
  bool? haveData1;
  bool? haveData2;
  int current = 0;

  //List<EpidemicModel> epidemicModels = [];
  List<InsectModel> insectModels = [];
  List<InsectModel> leaf_Feeder = [];
  List<InsectModel> juice_Sucker = [];
  List<InsectModel> stem_Borer = [];
  List<InsectModel> root_feeder = [];
  //EpidemicModel? epidemicModel;

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    if (insectModels.length != 0) {
      insectModels.clear();
    } else {}

    String apiGetInsectDataWhereId =
        '${MyConstant.domain}/insectFile/getInsectData.php?isAdd=true';

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
          });
          if (model.type == 'leaf_feeder') {
            setState(() {
              leaf_Feeder.add(model);
            });
          } else if (model.type == 'juice_sucker') {
            setState(() {
              juice_Sucker.add(model);
            });
          } else if (model.type == 'stem_borer') {
            setState(() {
              stem_Borer.add(model);
            });
          } else {
            setState(() {
              root_feeder.add(model);
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: load
          ? ShowProgress()
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: Column(
                    children: [
                      buildLeafFeeder(constraints, size, context),
                      buildJuiceSucker(constraints, size, context),
                      buildStemBorer(constraints, size, context),
                      buildRootFeeder(constraints, size, context),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Container buildJuiceSucker(
      BoxConstraints constraints, double size, BuildContext context) {
    return Container(
      //color: MyConstant.dark2,
      width: constraints.maxWidth,
      height: (constraints.maxHeight / 4) + 35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              'juice Sucker',
              style: GoogleFonts.jost(
                fontSize: 33,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: juice_Sucker.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(juice_Sucker[index].id),
                    builder: (context, constraints) => Container(
                      padding: EdgeInsets.only(bottom: 4, left: 5, right: 5),
                      child: InkWell(
                        onTap: () {
                          print(
                            '${juice_Sucker[index].type} => ${juice_Sucker[index].id}');
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowDetails1(
                                  insectModel: juice_Sucker[index]),
                            ),
                          ).then((value) => false);
                        },
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: createUrl(juice_Sucker[index].img),
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image1),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: size * 0.4,
                                  height: size * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Text(
                                '${juice_Sucker[index].name}',
                                style: GoogleFonts.prompt(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildRootFeeder(
      BoxConstraints constraints, double size, BuildContext context) {
    return Container(
      //color: MyConstant.dark2,
      width: constraints.maxWidth,
      height: (constraints.maxHeight / 4) + 35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              'Root Feeder',
              style: GoogleFonts.jost(
                fontSize: 33,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: root_feeder.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(root_feeder[index].id),
                    builder: (context, constraints) => Container(
                      padding: EdgeInsets.only(bottom: 4, left: 5, right: 5),
                      child: InkWell(
                        onTap: () {
                          print(
                            '${root_feeder[index].type} => ${root_feeder[index].id}');
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowDetails1(
                                  insectModel: root_feeder[index]),
                            ),
                          ).then((value) => false);
                        },
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: createUrl(root_feeder[index].img),
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image1),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: size * 0.4,
                                  height: size * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Text(
                                '${root_feeder[index].name}',
                                style: GoogleFonts.prompt(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildLeafFeeder(
      BoxConstraints constraints, double size, BuildContext context) {
    return Container(
      // color: MyConstant.dark2,
      width: constraints.maxWidth,
      height: (constraints.maxHeight / 4) + 35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              'Leaf Feeder',
              style: GoogleFonts.jost(
                fontSize: 33,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: leaf_Feeder.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(leaf_Feeder[index].id),
                    builder: (context, constraints) => Container(
                      padding: EdgeInsets.only(bottom: 4, left: 5, right: 5),
                      child: InkWell(
                        onTap: () {
                          print(
                              '${leaf_Feeder[index].type} => ${leaf_Feeder[index].id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowDetails1(insectModel: leaf_Feeder[index]),
                            ),
                          ).then((value) => false);
                        },
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: createUrl(leaf_Feeder[index].img),
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image1),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: size * 0.5,
                                  height: size * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Text(
                                '${leaf_Feeder[index].name}',
                                style: GoogleFonts.prompt(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildStemBorer(
      BoxConstraints constraints, double size, BuildContext context) {
    return Container(
      //color: MyConstant.dark2,
      width: constraints.maxWidth,
      height: (constraints.maxHeight / 4) + 35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              'Stem Borer',
              style: GoogleFonts.jost(
                fontSize: 33,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stem_Borer.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(stem_Borer[index].id),
                    builder: (context, constraints) => Container(
                      padding: EdgeInsets.only(bottom: 4, left: 5, right: 5),
                      child: InkWell(
                        onTap: () {
                          print(
                              '${stem_Borer[index].type} => ${stem_Borer[index].id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowDetails1(insectModel: stem_Borer[index]),
                            ),
                          ).then((value) => false);
                        },
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: createUrl(stem_Borer[index].img),
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image1),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: size * 0.5,
                                  height: size * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Text(
                                '${stem_Borer[index].name}',
                                style: GoogleFonts.prompt(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column buildRight(double size, BoxConstraints constraints) {
    return Column(
      children: [
        buildMenu1(size, constraints),
        buildMenu2(size, constraints),
        buildMenu3(size, constraints),
        buildMenu4(size, constraints),
      ],
    );
  }

  Container buildMenu4(double size, BoxConstraints constraints) {
    return Container(
      child: Center(
        child: RaisedButton(
            onPressed: () {
              current = 4;
              print('current => $current');
            },
            //color: MyConstant.primary,
            padding: EdgeInsets.symmetric(horizontal: 0),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              color: MyConstant.light,
              width: size * 0.3,
              height: constraints.maxHeight / 4,
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: Image.asset(MyConstant.root),
                ),
              ),
            )),
      ),
    );
  }

  Container buildMenu3(double size, BoxConstraints constraints) {
    return Container(
      child: Center(
        child: RaisedButton(
            onPressed: () {
              current = 3;
              print('current => $current');
            },
            //color: MyConstant.primary,
            padding: EdgeInsets.symmetric(horizontal: 0),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              color: MyConstant.primary,
              width: size * 0.3,
              height: constraints.maxHeight / 4,
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      //color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: Image.asset(MyConstant.trunk),
                ),
              ),
            )),
      ),
    );
  }

  Container buildMenu2(double size, BoxConstraints constraints) {
    return Container(
      child: Center(
        child: RaisedButton(
            onPressed: () {
              current = 2;
              print('current => $current');
            },
            //color: MyConstant.primary,
            padding: EdgeInsets.symmetric(horizontal: 0),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              color: MyConstant.dark,
              width: size * 0.3,
              height: constraints.maxHeight / 4,
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: Image.asset(MyConstant.flower),
                  //Icon(FontAwesomeIcons.tint),
                ),
              ),
            )),
      ),
    );
  }

  Container buildMenu1(double size, BoxConstraints constraints) {
    return Container(
      child: Center(
        child: RaisedButton(
            onPressed: () {
              current = 1;
              print('current => $current');
            },
            padding: EdgeInsets.symmetric(horizontal: 0),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              color: MyConstant.dark2,
              width: size * 0.3,
              height: constraints.maxHeight / 4,
              child: Center(
                child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        //color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: Image.asset(
                        MyConstant.coca) //Icon(FontAwesomeIcons.leaf),
                    ),
              ),
            )),
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
}
