import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showDetails1.dart';
import 'package:project001/Components/showDetails2.dart';
import 'package:project001/model/insectAll_model.dart';
import 'package:project001/model/insectLiteAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool status = false;
  bool load1 = true;
  bool load2 = true;
  bool haveData1 = false;
  bool haveData2 = false;
  bool flagColor = true;
  bool btnSearch = false;
  String? btnType;

  List<InsectAllModel> insectAllModels = [];
  List<InsectAllModel> _foundInsect = [];
  List<InsectLiteAllModel> insectLiteAllModels = [];
  List<InsectLiteAllModel> _foundInsectLite = [];

  @override
  initState() {
    super.initState();
    loadInsectAllFromAPI();
    loadInsectLiteAllFromAPI();
    _foundInsect = insectAllModels;
    _foundInsectLite = insectLiteAllModels;
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

  void _runFilter(String enteredKeyword) {
    List<InsectAllModel> results1 = [];
    List<InsectLiteAllModel> results2 = [];
    if (enteredKeyword.isEmpty) {
      // ไม่มีการค้นหา
      print('### ไม่มีการค้นหา');
      results1 = insectAllModels;
      results2 = insectLiteAllModels;
    } else {
      // ค้นหาชื่อ
      print('### ค้นหาชื่อ');
      results1 = insectAllModels
          .where((item) =>
              item.inName.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      results2 = insectLiteAllModels
          .where((item) =>
              item.inName.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundInsect = results1;
      _foundInsectLite = results2;
    });
  }

  Future<Null> loadInsectAllFromAPI() async {
    if (insectAllModels.length != 0) {
      insectAllModels.clear();
    } else {}
    String apiGetAllInsectData =
        '${MyConstant.domain}/insectFile/getAllInsectData.php?isAdd=true';
    try {
      await Dio().get(apiGetAllInsectData).then((value) {
        //print('value ==> $value');
        if (value.toString() == 'null') {
          // No Value
        } else {
          // Have Value
          for (var item in json.decode(value.data)) {
            InsectAllModel model = InsectAllModel.fromMap(item);
            setState(() {
              insectAllModels.add(model);
            });
          }
          setState(() {
            load1 = false;
            haveData1 = true;
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'ผิดพลาด', 'Network');
    }
  }

  Future<Null> loadInsectLiteAllFromAPI() async {
    if (insectLiteAllModels.length != 0) {
      insectLiteAllModels.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getAllInsectLite.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (value.toString() == 'null') {
            // print('value = empty');
          } else {
            // print('value = value');
            setState(() {
              load2 = false;
              haveData2 = true;
            });
            for (var item in json.decode(value.data)) {
              InsectLiteAllModel model = InsectLiteAllModel.fromMap(item);
              setState(() {
                insectLiteAllModels.add(model);
              });
            }
            // print('img ==> ${insectAllModels[0].inImg}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'ผิดพลาด', 'Network');
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        status = false;
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: load1
            ? ShowProgress()
            : haveData1
                ? SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) => Column(
                        children: [
                          buildSearchTextField(size),
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
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
                          ),
                          buildMenu(constraints),
                          flagColor
                              ? buildInsectData(context, constraints)
                              : buildInsectLite(context, constraints),
                        ],
                      ),
                    ),
                  )
                : Container(
                    child: Center(
                      child: Text('No Data'),
                    ),
                  ),
      ),
    );
  }

  Widget buildInsectData(BuildContext context, BoxConstraints constraints) {
    return haveData1
        ? Expanded(
            child: Container(
              color: Colors.white,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (constraints.maxWidth > 412) ? 4 : 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: _foundInsect.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(_foundInsect[index].inID),
                    builder: (context, constraints) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShowDetails1(id: _foundInsect[index].inID),
                          ),
                        );
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.5,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              MyConstant().subImage(_foundInsect[index].inImg),
                          placeholder: (context, url) =>
                              ShowImage(path: MyConstant.image),
                          errorWidget: (context, url, error) =>
                              ShowImage(path: MyConstant.image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : Expanded(
            child: Container(
              child: Center(
                child: Text('No Data'),
              ),
            ),
          );
  }

  Widget buildInsectLite(BuildContext context, BoxConstraints constraints) {
    return haveData2
        ? Expanded(
            child: Container(
            color: Colors.white,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (constraints.maxWidth > 412) ? 4 : 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: _foundInsectLite.length,
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  key: ValueKey(_foundInsectLite[index].inID),
                  builder: (context, constraints) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShowDetails2(id: insectLiteAllModels[index].inID),
                        ),
                      ).then((value) => false);
                    },
                    child: Container(
                      width: constraints.maxWidth * 0.5,
                      height: constraints.maxWidth * 0.4,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: MyConstant()
                            .subImage(_foundInsectLite[index].inImg),
                        placeholder: (context, url) =>
                            ShowImage(path: MyConstant.image),
                        errorWidget: (context, url, error) =>
                            ShowImage(path: MyConstant.image),
                      ),
                    ),
                  ),
                ); //Image.asset(MyConstant.image, fit: BoxFit.cover),
              },
            ),
          ))
        : Expanded(
            child: Container(
              child: Center(
                child: Text('No Data'),
              ),
            ),
          );
  }

  Widget buildMenu(BoxConstraints constraints) {
    return Container(
      color: Colors.white,
      width: constraints.maxWidth,
      height: 60,
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
                  'เพิ่มข้อมูลการพบแมลง',
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
                  'เพิ่มข้อมูลแมลง',
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
      color: Colors.white,
      padding: EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              width: status ? size * 0.8 : size * 0.96,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
}
