import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Member/editInsectData.dart';
import 'package:project001/User/post.dart';
import 'package:project001/model/insectAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonDetail.dart';
import 'package:project001/widgets/show_ButtonMap.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class ListInsectData extends StatefulWidget {
  const ListInsectData({Key? key}) : super(key: key);

  @override
  State<ListInsectData> createState() => _ListInsectDataState();
}

class _ListInsectDataState extends State<ListInsectData> {
  List<InsectAllModel> insectAllModels = [];
  bool haveData = false;
  bool load = true;
  bool btnSearch = false;
  bool status = false;
  String? btnType;
  List<InsectAllModel> _foundInsect = [];

  @override
  void initState() {
    super.initState();
    loadInsectDataFromAPI();
    _foundInsect = insectAllModels;
    print('----------Refresh----------');
  }

  Future<Null> loadInsectDataFromAPI() async {
    if (insectAllModels.length != 0) {
      insectAllModels.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getAllInsectData.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              InsectAllModel model = InsectAllModel.fromMap(item);
              setState(() {
                insectAllModels.add(model);
              });
            }
            setState(() {
              load = false;
              haveData = true;
            });
            print('### value length ==> ${insectAllModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<InsectAllModel> results1 = [];
    if (enteredKeyword.isEmpty) {
      // ไม่มีการค้นหา
      print('### ไม่มีการค้นหา');
      results1 = insectAllModels;
    } else {
      // ค้นหาชื่อ
      print('### ค้นหาชื่อ');
      results1 = insectAllModels
          .where((item) =>
              item.inName.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundInsect = results1;
    });
  }

  void _runMenu(String type) {
    List<InsectAllModel> results1 = [];
    print('### ค้นหาเมนู');
    if (btnSearch) {
      results1 =
          insectAllModels.where((item) => item.inType.contains(type)).toList();
    } else {
      results1 = insectAllModels;
    }

    setState(() {
      _foundInsect = results1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: buildAppbar(size),
      backgroundColor: Colors.grey[300],
      floatingActionButton: buildFloatButton(context),
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Container(
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8)
                      : constraints.maxWidth,
                  child: Column(
                    children: [
                      buildSearchTextField(size),
                      buildMenus(),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _foundInsect.length,
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                              builder: (context, constraints) => Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildHeader(index),
                                        buildCenter(index, constraints),
                                        buildDetails(index),
                                        buildFooter(index)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

// Dialog
  _myDialogDel(int index) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.del),
          title: Text(
            'ลบข้อมูล',
            style: GoogleFonts.prompt(fontSize: 16),
          ),
          subtitle: Text(
            'ต้องการที่จะลบข้อมูลนี้ หรือไม่',
            style: GoogleFonts.prompt(fontSize: 14),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: RaisedButton(
              onPressed: () async {
                await _functionDel(index, context);
              },
              color: Color(0xFFB22222),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "ยืนยัน",
                style: GoogleFonts.prompt(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: OutlineButton(
              highlightedBorderColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ยกเลิก",
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// function
  Future<void> _functionDel(int index, BuildContext context) async {
    print('### id => ${insectAllModels[index].inID}');
    String api =
        '${MyConstant.domain}/insectFile/deleteInsectDataWhereID.php?isAdd=true&id=${insectAllModels[index].inID}';
    await Dio().get(api).then(
      (value) {
        Navigator.pop(context);
        loadInsectDataFromAPI();
      },
    );
  }

// Widget

  Widget buildDetails(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_foundInsect[index].inName}',
          style: GoogleFonts.prompt(
            fontSize: 14,
            color: MyConstant.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${_foundInsect[index].inDetails}',
          style: GoogleFonts.prompt(
            fontSize: 12,
            color: MyConstant.dark2,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildCenter(int index, BoxConstraints constraints) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: MyConstant().subImage(_foundInsect[index].inImg),
      placeholder: (context, url) => ShowImage(path: MyConstant.image),
      errorWidget: (context, url, error) => ShowImage(path: MyConstant.image),
      imageBuilder: (context, imageProvider) => Container(
        width: constraints.maxWidth,
        height: constraints.maxWidth / 4,
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget buildFooter(int index) {
    return Row(
      children: [
        ShowButtonDetail(id: _foundInsect[index].inID),
        SizedBox(width: 2.0),
        ShowButtonMap(id: _foundInsect[index].inID),
      ],
    );
  }

  Widget buildHeader(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: '${MyConstant.domain}${_foundInsect[index].usImg}',
              errorWidget: (context, url, error) =>
                  ShowImage(path: MyConstant.avatar),
              imageBuilder: (context, imageProvider) => Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_foundInsect[index].usName}",
                    style: GoogleFonts.prompt(
                      fontSize: 12,
                      color: MyConstant.dark2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_foundInsect[index].usEmail}",
                    style: GoogleFonts.prompt(
                      fontSize: 12,
                      color: MyConstant.dark2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditInsectData(id: _foundInsect[index].inID)),
                ).then(
                  (value) => loadInsectDataFromAPI(),
                );
              },
              icon: Icon(
                FontAwesomeIcons.penToSquare,
                color: MyConstant.dark2,
                size: 20,
              ),
            ),
            IconButton(
              onPressed: () async {
                await _myDialogDel(index);
                // MyDialog(funcAction: functionDelete)
                //     .deleteDialog(context, insectAllModels[index].inID);
              },
              icon: Icon(
                FontAwesomeIcons.xmark,
                color: MyConstant.dark2,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMenus() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 0, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          buildMenu1(),
          SizedBox(
            width: 10,
          ),
          buildMenu2(),
          SizedBox(
            width: 10,
          ),
          buildMenu3(),
          SizedBox(
            width: 10,
          ),
          buildMenu4(),
        ]),
      ),
    );
  }

  Widget buildMenu4() {
    return RaisedButton(
      onPressed: () {
        setState(() {
          btnType = '3';
          btnSearch ? btnSearch = false : btnSearch = true;
          _runMenu(btnType!);
        });
      },
      color: Color(0xFFA9907E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ราก",
        style: GoogleFonts.prompt(),
      ),
    );
  }

  Widget buildMenu3() {
    return RaisedButton(
      onPressed: () {
        setState(() {
          btnType = '2';
          btnSearch ? btnSearch = false : btnSearch = true;
          _runMenu(btnType!);
        });
      },
      color: Color(0xFFF3DEBA),
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ลำต้น",
        style: GoogleFonts.prompt(),
      ),
    );
  }

  Widget buildMenu2() {
    return RaisedButton(
      onPressed: () {
        setState(() {
          btnType = '1';
          btnSearch ? btnSearch = false : btnSearch = true;
          _runMenu(btnType!);
        });
      },
      color: Color(0xFFABC4AA),
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ยอดอ่อน",
        style: GoogleFonts.prompt(),
      ),
    );
  }

  Widget buildMenu1() {
    return RaisedButton(
      onPressed: () {
        setState(() {
          btnType = '4';
          btnSearch ? btnSearch = false : btnSearch = true;
          _runMenu(btnType!);
        });
      },
      color: Color(0xFF675D50),
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ใบ",
        style: GoogleFonts.prompt(),
      ),
    );
  }

  Widget buildSearchTextField(double size) {
    return Container(
      padding: EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              width: status ? size * 0.8 : size * 0.96,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                onTap: () {
                  status = true;
                  print(status);
                },
                onChanged: (value) {
                  //print(val);
                  _runFilter(value);
                  print('### _runFilter ==> $value');
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(
                    FontAwesomeIcons.search,
                    size: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  status = false;
                  print(status);
                },
                child: status
                    ? Text(
                        'ยกเลิก',
                        style: GoogleFonts.prompt(
                          color: Colors.black,
                        ),
                      )
                    : Container())
          ],
        ),
      ),
    );
  }

  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Post(),
          ),
        ).then((value) => loadInsectDataFromAPI());
      },
      label: Text(
        'เพิ่มข้อมูล',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.w400,
          color: MyConstant.light,
        ),
      ),
      icon: Icon(
        FontAwesomeIcons.add,
        color: MyConstant.light,
      ),
      backgroundColor: MyConstant.dark,
    );
  }

  AppBar buildAppbar(double size) {
    return AppBar(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'Insect',
                style: GoogleFonts.lobster(
                  fontSize: 30,
                ),
              ),
              Text(
                ' | จัดการข้อมูลแมลง',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
