import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/insectLite.dart';
import 'package:project001/Components/showDetails1.dart';
import 'package:project001/model/insectLiteAll_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool load = true;
  bool haveData = false;
  int current = 0;
  List<InsectLiteAllModel> insecLiteAllModels = [];
  List<InsectModel> leaf_Feeder = [];
  List<InsectModel> juice_Sucker = [];
  List<InsectModel> stem_Borer = [];
  List<InsectModel> root_feeder = [];

  @override
  void initState() {
    super.initState();
    loadInsecLiteFromAPI();
    loadValueFromAPI();
    print('----------Refresh----------');
  }

  Future<Null> loadInsecLiteFromAPI() async {
    if (insecLiteAllModels.length != 0) {
      insecLiteAllModels.clear();
    }
    String apiGet =
        '${MyConstant.domain}/insectFile/getAllInsectLite.php?isAdd=true';
    try {
      await Dio().get(apiGet).then((value) {
        for (var item in json.decode(value.data)) {
          InsectLiteAllModel model = InsectLiteAllModel.fromMap(item);
          setState(() {
            insecLiteAllModels.add(model);
          });
        }
        print('### ListMain ==> ${insecLiteAllModels.length}');
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  Future<Null> loadValueFromAPI() async {
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectData.php?isAdd=true';
    try {
      await Dio().get(apiGet).then((value) {
        for (var item in json.decode(value.data)) {
          InsectModel model = InsectModel.fromMap(item);
          if (model.type == '1') {
            setState(() {
              juice_Sucker.add(model);
            });
          } else if (model.type == '2') {
            setState(() {
              stem_Borer.add(model);
            });
          } else if (model.type == '3') {
            setState(() {
              root_feeder.add(model);
            });
          } else {
            setState(() {
              leaf_Feeder.add(model);
            });
          }
        }
        setState(() {
          load = false;
          haveData = true;
        });
        print('### ListJuice_Sucker ==> ${juice_Sucker.length}');
        print('### ListLeaf_Feeder ==> ${leaf_Feeder.length}');
        print('### ListStem_Borer ==> ${stem_Borer.length}');
        print('### ListRoot_feeder ==> ${root_feeder.length}');
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
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
              builder: (context, constraints) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeadInsectLite(),
                    buildMenuMain(size, context),
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 12, top: 12),
                      child: InkWell(
                        onTap: () => print('#'),
                        child: Text(
                          'ประเภทความเสียหายที่เกิดจากแมลง',
                          style: GoogleFonts.prompt(
                            fontSize: 14,
                            color: MyConstant.dark2,
                          ),
                        ),
                      ),
                    ),
                    buildHeadJuiceSucker(),
                    buildJuiceSucker(size, context),
                    buildHeadLeafFeeder(),
                    buildLeafFeeder(size, context),
                    buildHeadStemBorer(),
                    buildStemBorer(size, context),
                    buildHeadRootFeeder(),
                    buildRootFeeder(size, context),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Container buildHeadInsectLite() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 12, bottom: 4),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsectLite(),
          ),
        ).then((value) => loadInsecLiteFromAPI()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ข้อมูลการพบแมลงแพร่ระบาด',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyConstant.dark2,
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
            )
          ],
        ),
      ),
    );
  }

  Container buildHeadJuiceSucker() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 12, bottom: 4),
      child: InkWell(
        onTap: () => print('#'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'แมลงจำพวกดูดกินน้ำเลี้ยง',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyConstant.dark2,
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
            )
          ],
        ),
      ),
    );
  }

  Container buildHeadLeafFeeder() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 12, top: 12, bottom: 4),
      child: InkWell(
        onTap: () => print('##'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'แมลงศัตรูพืชจำพวกกัดกินใบ',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyConstant.dark2,
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
            )
          ],
        ),
      ),
    );
  }

  Container buildHeadStemBorer() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 12, top: 12, bottom: 4),
      child: InkWell(
        onTap: () => print('###'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'แมลงศัตรูพืชจำพวกกัดกินลำต้น',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyConstant.dark2,
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
            )
          ],
        ),
      ),
    );
  }

  Container buildHeadRootFeeder() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 12, top: 12, bottom: 4),
      child: InkWell(
        onTap: () => print('####'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'แมลงศัตรูพืชจำพวกกัดกินราก',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyConstant.dark2,
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
            )
          ],
        ),
      ),
    );
  }

  Container buildMenuMain(double size, BuildContext context) {
    return Container(
      width: size * 1,
      height: size * 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: insecLiteAllModels.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(insecLiteAllModels[index].inID),
                    builder: (context, constraints) => Container(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          print(
                              '### ข้อมูลการพบแมลง:id => ${insecLiteAllModels[index].inID}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InsectLite()),
                          );
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: MyConstant()
                                  .subImage(insecLiteAllModels[index].inImg),
                              placeholder: (context, url) =>
                                  ShowImage(path: MyConstant.image),
                              errorWidget: (context, url, error) =>
                                  ShowImage(path: MyConstant.image),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: size * 0.93,
                                // height: size * 1,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: FractionalTranslation(
                                translation: Offset(0, 0),
                                child: Container(
                                  width: size * 1,
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${insecLiteAllModels[index].inName}',
                                        style: GoogleFonts.prompt(
                                          color: MyConstant.dark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'พบในพื้นที่:'
                                        ' ต.${insecLiteAllModels[index].inCounty}'
                                        ' อ.${insecLiteAllModels[index].inDistrict}'
                                        ' อ.${insecLiteAllModels[index].inProvince}',
                                        style: GoogleFonts.prompt(
                                          color: MyConstant.dark2,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Container buildJuiceSucker(double size, BuildContext context) {
    return Container(
      width: size * 1,
      height: size * 0.27,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: juice_Sucker.length,
        itemBuilder: (context, index) {
          return LayoutBuilder(
            key: ValueKey(juice_Sucker[index].id),
            builder: (context, constraints) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () {
                  print(
                      '${juice_Sucker[index].type} => ${juice_Sucker[index].id}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowDetails1(id: juice_Sucker[index].id),
                    ),
                  ).then((value) => false);
                },
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: MyConstant().subImage(juice_Sucker[index].img),
                      placeholder: (context, url) =>
                          ShowImage(path: MyConstant.image),
                      errorWidget: (context, url, error) =>
                          ShowImage(path: MyConstant.image),
                      imageBuilder: (context, imageProvider) => Container(
                        width: size * 0.46,
                        height: size * 1,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: FractionalTranslation(
                        translation: Offset(0, 0),
                        child: Container(
                          width: size * 1,
                          color: Color.fromRGBO(255, 255, 255, 0.5),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              '${juice_Sucker[index].name}',
                              style: GoogleFonts.prompt(
                                color: MyConstant.dark2,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Container buildLeafFeeder(double size, BuildContext context) {
    return Container(
      width: size * 1,
      height: size * 0.27,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          print(
                              '${leaf_Feeder[index].type} => ${leaf_Feeder[index].id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowDetails1(id: leaf_Feeder[index].id),
                            ),
                          ).then((value) => false);
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  MyConstant().subImage(leaf_Feeder[index].img),
                              placeholder: (context, url) =>
                                  ShowImage(path: MyConstant.image),
                              errorWidget: (context, url, error) =>
                                  ShowImage(path: MyConstant.image),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: size * 0.46,
                                height: size * 1,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: FractionalTranslation(
                                translation: Offset(0, 0),
                                child: Container(
                                  width: size * 1,
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Text(
                                      '${leaf_Feeder[index].name}',
                                      style: GoogleFonts.prompt(
                                        color: MyConstant.dark2,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Container buildStemBorer(double size, BuildContext context) {
    return Container(
      width: size * 1,
      height: size * 0.27,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          print(
                              '${stem_Borer[index].type} => ${stem_Borer[index].id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowDetails1(id: stem_Borer[index].id),
                            ),
                          ).then((value) => false);
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  MyConstant().subImage(stem_Borer[index].img),
                              placeholder: (context, url) =>
                                  ShowImage(path: MyConstant.image),
                              errorWidget: (context, url, error) =>
                                  ShowImage(path: MyConstant.image),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: size * 0.46,
                                height: size * 1,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: FractionalTranslation(
                                translation: Offset(0, 0),
                                child: Container(
                                  width: size * 1,
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Text(
                                      '${stem_Borer[index].name}',
                                      style: GoogleFonts.prompt(
                                        color: MyConstant.dark2,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Container buildRootFeeder(double size, BuildContext context) {
    return Container(
      width: size * 1,
      height: size * 0.27,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          print(
                              '${root_feeder[index].type} => ${root_feeder[index].id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowDetails1(id: root_feeder[index].id),
                            ),
                          ).then((value) => false);
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  MyConstant().subImage(root_feeder[index].img),
                              placeholder: (context, url) =>
                                  ShowImage(path: MyConstant.image),
                              errorWidget: (context, url, error) =>
                                  ShowImage(path: MyConstant.image),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: size * 0.46,
                                height: size * 1,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0.5,
                              bottom: 0.5,
                              child: FractionalTranslation(
                                translation: Offset(0, 0),
                                child: Container(
                                  width: size * 1,
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Text(
                                      '${root_feeder[index].name}',
                                      style: GoogleFonts.prompt(
                                        color: MyConstant.dark2,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  AppBar buildAppbar() {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Insect',
              style: GoogleFonts.lobster(
                fontSize: 30,
              ),
            ),
            Text(
              ' | ข้อมูลการพบแมลงแพร่ระบาด',
              style: GoogleFonts.prompt(
                fontSize: 14,
              ),
            ),
          ],
        ));
  }
}
